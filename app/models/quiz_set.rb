class QuizSet < ApplicationRecord
  belongs_to :quiz_setable, polymorphic: true
  has_many :quizzes, dependent: :destroy
  has_many :quiz_set_concepts, dependent: :destroy
  has_many :concepts, through: :quiz_set_concepts
end

