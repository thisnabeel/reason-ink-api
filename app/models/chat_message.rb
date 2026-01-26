class ChatMessage < ApplicationRecord
  belongs_to :chat_room
  belongs_to :user

  validates :content, presence: true

  after_create_commit :broadcast_message

  private

  def broadcast_message
    ChatChannel.broadcast_to(
      chat_room,
      {
        type: message_type || 'message',
        id: id,
        content: content,
        user_id: user_id,
        username: user.username,
        message_type: message_type || 'message',
        metadata: metadata ? JSON.parse(metadata) : nil,
        created_at: created_at
      }
    )
  end
end
