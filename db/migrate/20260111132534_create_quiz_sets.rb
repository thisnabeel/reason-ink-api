class CreateQuizSets < ActiveRecord::Migration[8.1]
  def change
    create_table :quiz_sets do |t|
      t.integer :quiz_setable_id
      t.string :quiz_setable_type
      t.integer :position
      t.string :title
      t.text :description
      t.boolean :pop_quizable

      t.timestamps
    end
  end
end
