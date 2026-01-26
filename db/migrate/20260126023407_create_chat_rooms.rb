class CreateChatRooms < ActiveRecord::Migration[8.1]
  def change
    create_table :chat_rooms do |t|
      t.references :chatroomable, polymorphic: true, null: false
      t.references :user1, null: false, foreign_key: { to_table: :users }
      t.references :user2, null: true, foreign_key: { to_table: :users }
      t.string :status, default: 'waiting'

      t.timestamps
    end
  end
end
