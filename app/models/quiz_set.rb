class QuizSet < ApplicationRecord
  belongs_to :quiz_setable, polymorphic: true
  has_many :quizzes, dependent: :destroy
end

