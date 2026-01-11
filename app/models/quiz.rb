class Quiz < ApplicationRecord
  belongs_to :quizable, polymorphic: true
  belongs_to :quiz_set, optional: true
  has_many :quiz_choices, dependent: :destroy
end

