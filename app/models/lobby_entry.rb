class LobbyEntry < ApplicationRecord
  belongs_to :chatroomable, polymorphic: true
  belongs_to :user

  enum :status, { waiting: 'waiting', matched: 'matched', cancelled: 'cancelled' }

  validates :status, presence: true

  scope :waiting_for, ->(chatroomable) { where(chatroomable: chatroomable, status: 'waiting') }
end
