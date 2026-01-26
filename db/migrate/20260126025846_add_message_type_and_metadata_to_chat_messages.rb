class AddMessageTypeAndMetadataToChatMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :chat_messages, :message_type, :string
    add_column :chat_messages, :metadata, :text
  end
end
