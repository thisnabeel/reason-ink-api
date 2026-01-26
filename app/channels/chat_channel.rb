class ChatChannel < ApplicationCable::Channel
  def subscribed
    @chat_room = ChatRoom.find(params[:room_id])
    
    unless @chat_room.participants.include?(current_user)
      reject
      return
    end

    stream_for @chat_room
    
    # Broadcast that this user came online
    broadcast_presence('online')
  end

  def unsubscribed
    # Broadcast that this user went offline
    if @chat_room
      broadcast_presence('offline')
    end
  end

  def receive(data)
    # Handle typing indicators
    if data['type'] == 'typing'
      other_user = @chat_room.other_user(current_user)
      return unless other_user
      
      # Broadcast typing indicator to the other user
      ChatChannel.broadcast_to(@chat_room, {
        type: 'typing',
        user_id: current_user.id,
        username: current_user.username
      })
    end
  end

  private

  def broadcast_presence(status)
    other_user = @chat_room.other_user(current_user)
    return unless other_user

    # Broadcast to the other user
    LobbyChannel.broadcast_to(other_user, {
      type: 'presence',
      chat_room_id: @chat_room.id,
      user_id: current_user.id,
      status: status
    })
  end
end

