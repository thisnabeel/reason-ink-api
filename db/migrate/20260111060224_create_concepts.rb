class CreateConcepts < ActiveRecord::Migration[8.1]
  def change
    create_table :concepts do |t|
      t.string :title
      t.string :avatar_url
      t.integer :start_year
      t.integer :end_year
      t.string :concept_type
      t.integer :concept_id

      t.timestamps
    end

    add_index :concepts, :concept_id
  end
end
