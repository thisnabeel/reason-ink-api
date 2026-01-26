class AddCurrentExperimentToChatRooms < ActiveRecord::Migration[8.1]
  def change
    add_reference :chat_rooms, :current_experiment, null: true, foreign_key: { to_table: :experiments }
  end
end
