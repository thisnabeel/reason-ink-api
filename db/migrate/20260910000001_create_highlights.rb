class CreateHighlights < ActiveRecord::Migration[8.1]
  def change
    create_table :highlights do |t|
      t.references :chapter, null: false, foreign_key: true
      t.string :title
      t.text :transcript
      t.float :offset_seconds, null: false, default: 0.0
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :highlights, [:chapter_id, :position]
    add_index :highlights, [:chapter_id, :offset_seconds]
  end
end
