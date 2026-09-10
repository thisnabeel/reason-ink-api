require "net/http"
require "json"
require "uri"

class Supadata
  BASE_URL = "https://api.supadata.ai/v1".freeze

  def self.transcript(url, lang: "en", mode: "native")
    raise "SUPADATA_API_KEY is not set" if api_key.blank?

    uri = URI("#{BASE_URL}/transcript")
    uri.query = URI.encode_www_form(
      url: url,
      lang: lang,
      mode: mode
    )

    response = get(uri)
    body = parse_json(response)

    if body["jobId"].present?
      body = poll_job(body["jobId"])
    end

    if body["error"].present?
      raise "Supadata error: #{body['message'] || body['error']}"
    end

    body
  end

  # https://docs.supadata.ai/get-metadata
  def self.metadata(url)
    raise "SUPADATA_API_KEY is not set" if api_key.blank?

    uri = URI("#{BASE_URL}/metadata")
    uri.query = URI.encode_www_form(url: url)

    response = get(uri)
    body = parse_json(response)

    if body["error"].present?
      raise "Supadata error: #{body['message'] || body['error']}"
    end

    body
  end

  def self.video_title(url)
    meta = metadata(url)
    meta["title"].presence
  end

  def self.video_duration(url)
    meta = metadata(url)
    duration =
      meta.dig("media", "duration") ||
      meta["duration"] ||
      meta.dig("additionalData", "duration")
    duration.present? ? duration.to_f : nil
  end

  def self.format_transcript_for_prompt(transcript)
    normalized_chunks(transcript).map do |chunk|
      "#{format_timestamp(chunk[:seconds])} #{chunk[:text]}"
    end.join("\n")
  end

  def self.normalized_chunks(transcript)
    content = transcript["content"]
    return [] if content.blank?
    return [{ seconds: 0.0, text: content.to_s }] if content.is_a?(String)

    content.map do |chunk|
      offset = chunk["offset"].to_f
      # Playground returns seconds; OpenAPI docs sometimes list milliseconds.
      seconds = offset > 10_000 ? offset / 1000.0 : offset
      { seconds: seconds, text: chunk["text"].to_s }
    end
  end

  def self.transcript_between(chunks, start_seconds, end_seconds = nil)
    selected = chunks.select do |chunk|
      chunk[:seconds] >= start_seconds && (end_seconds.nil? || chunk[:seconds] < end_seconds)
    end
    selected.map { |chunk| chunk[:text] }.join(" ").squish
  end

  def self.format_timestamp(total_seconds)
    total = total_seconds.to_i
    hours = total / 3600
    minutes = (total % 3600) / 60
    seconds = total % 60

    if hours > 0
      format("%d:%02d:%02d", hours, minutes, seconds)
    else
      format("%02d:%02d", minutes, seconds)
    end
  end

  def self.api_key
    ENV["SUPADATA_API_KEY"].to_s.strip
  end

  def self.get(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 30
    http.read_timeout = 120

    request = Net::HTTP::Get.new(uri)
    request["x-api-key"] = api_key
    request["Content-Type"] = "application/json"

    http.request(request)
  end

  def self.parse_json(response)
    JSON.parse(response.body)
  rescue JSON::ParserError
    raise "Supadata returned invalid JSON (HTTP #{response.code})"
  end

  def self.poll_job(job_id, max_attempts: 60, interval: 2)
    max_attempts.times do
      uri = URI("#{BASE_URL}/transcript/#{job_id}")
      response = get(uri)
      body = parse_json(response)

      status = body["status"].to_s
      return body if body["content"].present? && status.blank?
      return body if status == "completed"
      raise "Supadata job failed: #{body['message'] || body['error'] || 'unknown'}" if status == "failed"

      sleep interval
    end

    raise "Supadata transcript job timed out"
  end

  private_class_method :api_key, :get, :parse_json, :poll_job
end
