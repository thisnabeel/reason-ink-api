class ChatRoom < ApplicationRecord
  belongs_to :chatroomable, polymorphic: true
  belongs_to :user1, class_name: 'User'
  belongs_to :user2, class_name: 'User', optional: true
  belongs_to :current_experiment, class_name: 'Experiment', optional: true
  has_many :chat_messages, dependent: :destroy

  enum :status, { waiting: 'waiting', active: 'active', closed: 'closed' }

  validates :status, presence: true

  def participants
    [user1, user2].compact
  end

  def other_user(current_user)
    return user2 if current_user == user1
    return user1 if current_user == user2
    nil
  end
end
