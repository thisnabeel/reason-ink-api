class CreateQuizSetConcepts < ActiveRecord::Migration[8.1]
  def change
    create_table :quiz_set_concepts do |t|
      t.references :quiz_set, null: false, foreign_key: true
      t.references :concept, null: false, foreign_key: true

      t.timestamps
    end
  end
end
