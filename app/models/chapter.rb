class Chapter < ApplicationRecord
  # Self-referential association: a chapter can belong to another chapter
  belongs_to :parent_chapter, class_name: "Chapter", foreign_key: "chapter_id", optional: true
  has_many :child_chapters, class_name: "Chapter", foreign_key: "chapter_id", dependent: :nullify
  has_many :highlights, -> { order(:position, :start_time, :id) }, dependent: :destroy

  YOUTUBE_HOSTS = %w[youtube.com youtu.be m.youtube.com].freeze

  before_validation :resolve_youtube_input, on: :create
  after_create :auto_generate_notes_from_youtube

  DEFAULT_NOTES_PROMPT = <<~PROMPT.freeze
    Give me a timestamped list of main topics from this video transcript.
    Return JSON only (no markdown fences) in this exact shape:
    {"highlights":[{"timestamp":"00:00","title":"Topic title"},{"timestamp":"01:19","title":"Next topic"}]}
    Use MM:SS for times under an hour, or H:MM:SS for longer videos.
    Keep each title to a short topic / summary, not full dialogue.
  PROMPT

  def self.youtube_url?(value)
    uri = URI.parse(value.to_s.strip)
    host = uri.host.to_s.downcase.sub(/\Awww\./, "")
    return false unless YOUTUBE_HOSTS.include?(host)

    if host == "youtu.be"
      return uri.path.to_s.match?(%r{\A/[\w\-]+})
    end

    path = uri.path.to_s
    query = URI.decode_www_form(uri.query.to_s).to_h
    return true if path == "/watch" && query["v"].present?
    path.match?(%r{\A/(shorts|live|embed)/[\w\-]+})
  rescue URI::InvalidURIError
    false
  end

  def resolve_youtube_input
    raw_title = title.to_s.strip
    raw_url = youtube_url.to_s.strip

    if raw_url.blank? && self.class.youtube_url?(raw_title)
      self.youtube_url = raw_title
      self.title = nil
    end

    return if youtube_url.blank?
    return if title.present? && !self.class.youtube_url?(title)

    fetched = begin
      Supadata.video_title(youtube_url)
    rescue StandardError => e
      Rails.logger.warn("YouTube title lookup failed: #{e.message}")
      nil
    end
    self.title = fetched.presence || "Untitled Chapter"
  end

  def auto_generate_notes_from_youtube
    return if youtube_url.blank?
    return if highlights.exists? || notes.present?

    generate_notes!
  rescue StandardError => e
    Rails.logger.warn("Auto notes generation failed for chapter #{id}: #{e.message}")
  end

  def generate_notes!(prompt = nil)
    raise "YouTube URL is required" if youtube_url.blank? && notes.blank?

    chunks = []
    transcript_text = nil

    if youtube_url.present?
      begin
        transcript = Supadata.transcript(youtube_url)
        chunks = Supadata.normalized_chunks(transcript)
        transcript_text = Supadata.format_transcript_for_prompt(transcript)
      rescue StandardError => e
        Rails.logger.warn("Transcript fetch failed for chapter #{id}: #{e.message}")
      end
    end

    if transcript_text.blank? && notes.present?
      transcript_text = notes.to_s
                             .gsub(/<br\s*\/?>/i, "\n")
                             .gsub(/<\/(p|li|div)>/i, "\n")
                             .gsub(/<[^>]*>/, " ")
                             .gsub("&nbsp;", " ")
                             .gsub(/\s+/, " ")
                             .strip
      chunks = []
    end

    raise "No transcript content returned" if transcript_text.blank?

    # Keep prompts under OpenAI TPM limits for long videos
    max_transcript_chars = 45_000
    if transcript_text.length > max_transcript_chars
      transcript_text = transcript_text[0, max_transcript_chars] + "\n\n[Transcript truncated for length]"
    end

    user_prompt = prompt.presence || DEFAULT_NOTES_PROMPT
    full_prompt = <<~PROMPT
      #{user_prompt}

      Transcript:
      #{transcript_text}
    PROMPT

    res = ChatGpt.send(full_prompt)
    raise res["error"] if res["error"].present?

    topics = extract_highlight_topics(res)
    raise "Failed to generate notes: Invalid response format" if topics.blank?

    video_end = resolve_video_duration_seconds(chunks)

    transaction do
      highlights.destroy_all

      topics.each_with_index do |topic, index|
        start_seconds = topic[:seconds].to_f
        end_seconds = topics[index + 1]&.dig(:seconds)
        end_seconds = if end_seconds.present?
          [end_seconds.to_f, start_seconds].max
        elsif video_end && video_end > start_seconds
          video_end
        else
          start_seconds
        end
        segment = chunks.present? ? Supadata.transcript_between(chunks, start_seconds, end_seconds) : ""

        highlights.create!(
          title: topic[:title],
          transcript: segment,
          start_time: start_seconds,
          end_time: end_seconds,
          position: index
        )
      end

      update!(notes: notes_html_from_highlights)
    end

    reload
    self
  end

  def notes_html_from_highlights
    lines = highlights.map { |h| "#{h.timestamp_label} – #{h.title}" }
    "<div>#{lines.join("<br>\n")}</div>"
  end

  # Convert legacy notes HTML into Highlight records.
  # Uses existing timestamps/titles from notes; fills transcript from YouTube when possible.
  def backfill_highlights_from_notes!
    topics = parse_topics_from_text(notes).map do |item|
      {
        seconds: parse_timestamp_to_seconds(item["timestamp"]),
        title: item["title"].to_s.strip
      }
    end
    raise "No timestamped topics found in notes" if topics.blank?

    chunks = []
    if youtube_url.present?
      begin
        transcript = Supadata.transcript(youtube_url)
        chunks = Supadata.normalized_chunks(transcript)
      rescue StandardError => e
        Rails.logger.warn("Transcript fetch failed for chapter #{id}: #{e.message}")
      end
    end

    video_end = resolve_video_duration_seconds(chunks)

    transaction do
      highlights.destroy_all

      topics.each_with_index do |topic, index|
        start_seconds = topic[:seconds].to_f
        end_seconds = topics[index + 1]&.dig(:seconds)
        end_seconds = if end_seconds.present?
          [end_seconds.to_f, start_seconds].max
        elsif video_end && video_end > start_seconds
          video_end
        else
          start_seconds
        end
        segment = chunks.present? ? Supadata.transcript_between(chunks, start_seconds, end_seconds) : ""

        highlights.create!(
          title: topic[:title],
          transcript: segment,
          start_time: start_seconds,
          end_time: end_seconds,
          position: index
        )
      end

      update!(notes: notes_html_from_highlights)
    end

    highlights.reload.size
  end

  # Recompute end_time from the next positioned highlight (and video duration for the last).
  def sync_highlight_end_times!(video_end = nil, fetch_duration: false)
    ordered = highlights.reload.to_a
    return 0 if ordered.empty?

    if video_end.nil? && fetch_duration
      video_end = resolve_video_duration_seconds
    end
    video_end ||= ordered.map { |h| h.start_time.to_f }.max

    ordered.each_with_index do |highlight, index|
      start_time = highlight.start_time.to_f
      next_highlight = ordered[index + 1]
      end_time = if next_highlight
        [next_highlight.start_time.to_f, start_time].max
      elsif video_end && video_end > start_time
        video_end
      else
        [highlight.end_time.to_f, start_time].max
      end

      highlight.update_columns(end_time: end_time, updated_at: Time.current)
    end

    ordered.size
  end

  def resolve_video_duration_seconds(chunks = nil)
    if youtube_url.present?
      duration = begin
        Supadata.video_duration(youtube_url)
      rescue StandardError => e
        Rails.logger.warn("Video duration lookup failed for chapter #{id}: #{e.message}")
        nil
      end
      return duration if duration.present? && duration > 0
    end

    if chunks.present?
      last = chunks.map { |c| c[:seconds].to_f }.max
      return last if last && last > 0
    end

    highlights.maximum(:start_time)&.to_f
  end

  def as_json(options = {})
    super(options).merge("highlights" => highlights.as_json)
  end

  def parse_topics_from_text(text)
    html = text.to_s
    normalized = html
                 .gsub(/<br\s*\/?>/i, "\n")
                 .gsub(/<\/(p|li|div|h\d)>/i, "\n")
                 .gsub(/<[^>]*>/, "")
                 .gsub("&nbsp;", " ")
                 .gsub(/\r\n?/, "\n")

    lines = normalized.split(/\n+/).map { |line| line.gsub(/\s+/, " ").strip }.reject(&:blank?)
    topics = lines.filter_map { |line| parse_topic_line(line) }
    return topics if topics.any?

    # Fallback for pasted ChatGPT blobs: scan for timestamp patterns inline
    normalized.scan(/(\d{1,2}:\d{2}(?::\d{2})?)\s*[–—\-]\s*(?:\d{1,2}:\d{2}(?::\d{2})?\s*(?:[–—\-→]|->)\s*)?([^\n\d].{2,160}?)(?=(?:\d{1,2}:\d{2})|\z)/)
              .filter_map do |timestamp, title|
                cleaned_title = title.to_s.gsub(/\s+/, " ").strip.sub(/\s*[→\-].*\z/, "").strip
                next if cleaned_title.blank?

                { "timestamp" => timestamp, "title" => cleaned_title }
              end
  end

  def parse_topic_line(line)
    cleaned = line.to_s.strip

    # [00:00:00] Title — description
    bracket = cleaned.match(/\A\[(\d{1,2}:\d{2}(?::\d{2})?)\]\s*(.+)\z/)
    if bracket
      title = bracket[2].to_s.strip.sub(/\s*[–—\-].*\z/, "").strip
      return { "timestamp" => bracket[1], "title" => title } if title.present?
    end

    # 00:00 – Title
    # 00:00:00 – 00:00:34 → Title
    # 00:00:00-00:00:34 – Title
    match = cleaned.match(
      /\A\*?\*?(\d{1,2}:\d{2}(?::\d{2})?)(?:\s*[–—\-]\s*\d{1,2}:\d{2}(?::\d{2})?)?\*?\*?\s*(?:[–—\-→]|->)\s*(.+)\z/
    )
    return nil unless match

    title = match[2].to_s.strip
                    .sub(/\A\d{1,2}:\d{2}(?::\d{2})?\s*(?:[–—\-→]|->)\s*/, "")
                    .strip
    return nil if title.blank?

    { "timestamp" => match[1], "title" => title }
  end

  def parse_timestamp_to_seconds(timestamp)
    parts = timestamp.to_s.split(":").map(&:to_i)
    case parts.length
    when 3
      parts[0] * 3600 + parts[1] * 60 + parts[2]
    when 2
      parts[0] * 60 + parts[1]
    else
      0
    end
  end

  private

  def extract_highlight_topics(res)
    raw =
      if res["highlights"].is_a?(Array)
        res["highlights"]
      elsif res["notes"].present? || res["answer"].present?
        parse_topics_from_text(res["notes"].presence || res["answer"])
      else
        []
      end

    raw.filter_map do |item|
      if item.is_a?(Hash)
        timestamp = item["timestamp"] || item[:timestamp] || item["time"] || item[:time]
        title = item["title"] || item[:title] || item["topic"] || item[:topic]
      else
        next
      end

      next if timestamp.blank? || title.blank?

      {
        seconds: parse_timestamp_to_seconds(timestamp),
        title: title.to_s.strip
      }
    end
  end
end
