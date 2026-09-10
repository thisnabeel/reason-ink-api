class AddStartAndEndTimeToHighlights < ActiveRecord::Migration[8.1]
  def up
    add_column :highlights, :start_time, :float, null: false, default: 0.0
    add_column :highlights, :end_time, :float, null: false, default: 0.0

    # Copy existing offsets into start_time, then set end_time from the next
    # positioned highlight in the same chapter (last highlight keeps start_time as end for now).
    say_with_time "backfilling highlight start_time/end_time" do
      Chapter.find_each do |chapter|
        highlights = chapter.highlights.order(:position, :offset_seconds, :id).to_a
        highlights.each_with_index do |highlight, index|
          start_time = highlight.offset_seconds.to_f
          next_highlight = highlights[index + 1]
          end_time = if next_highlight
            [next_highlight.offset_seconds.to_f, start_time].max
          else
            start_time
          end

          highlight.update_columns(
            start_time: start_time,
            end_time: end_time,
            updated_at: Time.current
          )
        end
      end
    end

    remove_index :highlights, column: [:chapter_id, :offset_seconds], if_exists: true
    remove_column :highlights, :offset_seconds
    add_index :highlights, [:chapter_id, :start_time]
    add_index :highlights, [:chapter_id, :end_time]
  end

  def down
    add_column :highlights, :offset_seconds, :float, null: false, default: 0.0

    Highlight.reset_column_information
    Highlight.find_each do |highlight|
      highlight.update_columns(offset_seconds: highlight.start_time.to_f)
    end

    remove_index :highlights, column: [:chapter_id, :start_time], if_exists: true
    remove_index :highlights, column: [:chapter_id, :end_time], if_exists: true
    remove_column :highlights, :start_time
    remove_column :highlights, :end_time
    add_index :highlights, [:chapter_id, :offset_seconds]
  end
end
