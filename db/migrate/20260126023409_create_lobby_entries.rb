class CreateLobbyEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :lobby_entries do |t|
      t.references :chatroomable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.string :status, default: 'waiting'

      t.timestamps
    end
  end
end
