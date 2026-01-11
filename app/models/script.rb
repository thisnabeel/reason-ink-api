class Script < ApplicationRecord
  belongs_to :scriptable, polymorphic: true

  validates :title, presence: true
  validates :scriptable_type, presence: true
  validates :scriptable_id, presence: true
  validates :position, numericality: { only_integer: true, allow_nil: true }

  default_scope { order(position: :asc) }
end

