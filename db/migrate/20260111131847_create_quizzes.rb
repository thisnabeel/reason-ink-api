class CreateQuizzes < ActiveRecord::Migration[8.1]
  def change
    create_table :quizzes do |t|
      t.string :quizable_type
      t.integer :quizable_id
      t.boolean :jeopardy, default: true
      t.text :question
      t.integer :position

      t.timestamps
    end
  end
end
