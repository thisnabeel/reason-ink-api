class AddQuizSetIdToQuizzes < ActiveRecord::Migration[8.1]
  def change
    add_column :quizzes, :quiz_set_id, :integer
  end
end
