class LobbyController < ApplicationController
  before_action :authenticate_user_from_token!

  def join
    chatroomable_type = params[:chatroomable_type]
    chatroomable_id = params[:chatroomable_id]
    
    chatroomable = chatroomable_type.constantize.find(chatroomable_id)
    
    # Check if user already has a waiting entry
    existing_entry = LobbyEntry.find_by(
      chatroomable: chatroomable,
      user: current_user,
      status: 'waiting'
    )

    if existing_entry
      return render json: { 
        status: 'waiting',
        lobby_entry_id: existing_entry.id,
        message: 'Already in lobby'
      }
    end

    # Try to find a match
    waiting_entry = LobbyEntry.waiting_for(chatroomable)
                                .where.not(user: current_user)
                                .first

    if waiting_entry
      # Check if there's already a chat room for this match
      existing_room = ChatRoom.find_by(
        chatroomable: chatroomable,
        user1: waiting_entry.user,
        user2: nil,
        status: 'waiting'
      )

      if existing_room
        # Update existing room
        existing_room.update(user2: current_user, status: 'active')
        chat_room = existing_room
      else
        # Create new chat room with both users
        chat_room = ChatRoom.create!(
          chatroomable: chatroomable,
          user1: waiting_entry.user,
          user2: current_user,
          status: 'active'
        )
      end

      # Update waiting entry
      waiting_entry.update(status: 'matched')

      # Broadcast match to host (user1) - they should be redirected
      LobbyChannel.broadcast_to(waiting_entry.user, {
        type: 'matched',
        chat_room: format_chat_room_for_broadcast(chat_room),
        message: 'Someone joined your room!'
      })

      # Broadcast match to joiner (user2) - they should be redirected
      LobbyChannel.broadcast_to(current_user, {
        type: 'matched',
        chat_room: format_chat_room_for_broadcast(chat_room),
        message: 'Match found!'
      })

      render json: {
        status: 'matched',
        chat_room: format_chat_room_for_broadcast(chat_room)
      }
    else
      # No match found, create a waiting room and add to lobby
      chat_room = ChatRoom.create!(
        chatroomable: chatroomable,
        user1: current_user,
        status: 'waiting'
      )

      lobby_entry = LobbyEntry.create!(
        chatroomable: chatroomable,
        user: current_user,
        status: 'waiting'
      )

      render json: {
        status: 'waiting',
        lobby_entry_id: lobby_entry.id,
        chat_room: format_chat_room_for_broadcast(chat_room),
        message: 'Waiting for match...'
      }
    end
  end

  def leave
    chatroomable_type = params[:chatroomable_type]
    chatroomable_id = params[:chatroomable_id]
    
    chatroomable = chatroomable_type.constantize.find(chatroomable_id)
    
    lobby_entry = LobbyEntry.find_by(
      chatroomable: chatroomable,
      user: current_user,
      status: 'waiting'
    )

    if lobby_entry
      lobby_entry.update(status: 'cancelled')
      render json: { message: 'Left lobby' }
    else
      render json: { message: 'Not in lobby' }, status: :not_found
    end
  end

  def status
    chatroomable_type = params[:chatroomable_type]
    chatroomable_id = params[:chatroomable_id]
    
    chatroomable = chatroomable_type.constantize.find(chatroomable_id)
    
    lobby_entry = LobbyEntry.find_by(
      chatroomable: chatroomable,
      user: current_user,
      status: 'waiting'
    )

    if lobby_entry
      render json: {
        status: 'waiting',
        lobby_entry_id: lobby_entry.id
      }
    else
      render json: {
        status: 'not_in_lobby'
      }
    end
  end

  private

  def format_chat_room_for_broadcast(room)
    {
      id: room.id,
      chatroomable_type: room.chatroomable_type,
      chatroomable_id: room.chatroomable_id,
      chatroomable: {
        id: room.chatroomable.id,
        title: room.chatroomable.respond_to?(:title) ? room.chatroomable.title : nil,
        body: room.chatroomable.respond_to?(:body) ? room.chatroomable.body : nil
      },
      user1: {
        id: room.user1.id,
        username: room.user1.username
      },
      user2: room.user2 ? {
        id: room.user2.id,
        username: room.user2.username
      } : nil,
      status: room.status
    }
  end
end

