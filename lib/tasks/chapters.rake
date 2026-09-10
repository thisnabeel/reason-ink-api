# frozen_string_literal: true

namespace :chapters do
  desc "Backfill Highlight records from existing notes HTML (and YouTube transcripts when available)"
  task backfill_highlights: :environment do
    force = ENV["FORCE"] == "1"

    scope = Chapter.all
    unless force
      scope = scope.left_outer_joins(:highlights).where(highlights: { id: nil }).distinct
    end

    chapters = scope.to_a
    puts "Backfilling #{chapters.size} chapter(s)#{force ? " (FORCE)" : ""}..."

    ok = 0
    regenerated = 0
    skipped = 0
    failed = 0

    chapters.each do |chapter|
      begin
        if force
          chapter.highlights.destroy_all
        elsif chapter.highlights.exists?
          skipped += 1
          next
        end

        topics = chapter.parse_topics_from_text(chapter.notes)
        if topics.present?
          count = chapter.backfill_highlights_from_notes!
          puts "OK   chapter=#{chapter.id} highlights=#{count} source=notes title=#{chapter.title.to_s[0, 70]}"
          ok += 1
        elsif chapter.youtube_url.present?
          chapter.generate_notes!
          count = chapter.highlights.reload.size
          puts "GEN  chapter=#{chapter.id} highlights=#{count} source=openai title=#{chapter.title.to_s[0, 70]}"
          regenerated += 1
        else
          skipped += 1
          puts "SKIP chapter=#{chapter.id} (no parseable notes / youtube) title=#{chapter.title.to_s[0, 70]}"
        end
      rescue StandardError => e
        failed += 1
        puts "FAIL chapter=#{chapter.id}: #{e.class} #{e.message}"
      end
    end

    puts "Done. ok=#{ok} regenerated=#{regenerated} skipped=#{skipped} failed=#{failed}"
  end

  desc "Recompute highlight end_time from next positioned highlight (and video duration for last)"
  task sync_highlight_end_times: :environment do
    fetch_duration = ENV["FETCH_DURATION"] == "1"
    total = 0
    Chapter.find_each do |chapter|
      next unless chapter.highlights.exists?

      count = chapter.sync_highlight_end_times!(fetch_duration: fetch_duration)
      total += count
      puts "synced chapter=#{chapter.id} highlights=#{count}"
    end
    puts "Done. highlights=#{total} fetch_duration=#{fetch_duration}"
  end
end
