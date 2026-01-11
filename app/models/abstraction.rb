class Abstraction < ApplicationRecord
  belongs_to :abstractable, polymorphic: true
end

