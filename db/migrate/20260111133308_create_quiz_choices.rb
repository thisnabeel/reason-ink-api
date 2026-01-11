class CreateQuizChoices < ActiveRecord::Migration[8.1]
  def change
    create_table :quiz_choices do |t|
      t.belongs_to :quiz, null: false, foreign_key: true
      t.integer :position
      t.boolean :correct, default: false
      t.text :body

      t.timestamps
    end
  end
end
