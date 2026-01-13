class Concept < ApplicationRecord
  # Self-referential association: a concept can belong to another concept
  belongs_to :parent_concept, class_name: "Concept", foreign_key: "concept_id", optional: true
  has_many :child_concepts, class_name: "Concept", foreign_key: "concept_id", dependent: :nullify

  # Polymorphic associations
  has_many :abstractions, as: :abstractable, dependent: :destroy
  has_many :quiz_sets, as: :quiz_setable, dependent: :destroy
  has_many :quizzes, as: :quizable, dependent: :destroy
  has_many :scripts, as: :scriptable, dependent: :destroy
  
  # Direct associations
  has_many :phrases, dependent: :destroy
  has_many :examples, dependent: :destroy
  
  # Many-to-many association with experiments
  has_many :concept_experiments, dependent: :destroy
  has_many :experiments, through: :concept_experiments

  # Enum for concept_type
  enum :concept_type, {
    person: "person",
    idea: "idea",
    movement: "movement",
    book: "book"
  }

  # Validations
  validates :title, presence: true
  validates :concept_type, presence: true
  validates :start_year, numericality: { only_integer: true, allow_nil: true }
  validates :end_year, numericality: { only_integer: true, allow_nil: true }
  validate :end_year_after_start_year

  private

  def end_year_after_start_year
    return if start_year.nil? || end_year.nil?

    errors.add(:end_year, "must be after start_year") if end_year < start_year
  end
end

