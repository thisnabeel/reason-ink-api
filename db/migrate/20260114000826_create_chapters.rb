class CreateChapters < ActiveRecord::Migration[8.1]
  def change
    create_table :chapters do |t|
      t.integer :chapter_id
      t.text :notes
      t.text :youtube_url
      t.text :body

      t.timestamps
    end

    add_index :chapters, :chapter_id
  end
end
