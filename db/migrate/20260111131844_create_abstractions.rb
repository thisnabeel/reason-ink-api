class CreateAbstractions < ActiveRecord::Migration[8.1]
  def change
    create_table :abstractions do |t|
      t.integer :abstractable_id
      t.string :abstractable_type
      t.text :article
      t.integer :last_edited_by
      t.string :preview
      t.integer :position
      t.string :source_url
      t.text :body

      t.timestamps
    end
  end
end
