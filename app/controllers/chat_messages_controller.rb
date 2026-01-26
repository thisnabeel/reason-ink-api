class ChatMessagesController < ApplicationController
  before_action :authenticate_user_from_token!

  def index
    chat_room = ChatRoom.find(params[:chat_room_id])
    
    unless chat_room.participants.include?(current_user)
      return head(:forbidden)
    end

    messages = chat_room.chat_messages.includes(:user).order(created_at: :asc)
    render json: messages.map { |msg| format_message(msg) }
  end

  def create
    chat_room = ChatRoom.find(params[:chat_room_id])
    
    unless chat_room.participants.include?(current_user)
      return head(:forbidden)
    end

    message = chat_room.chat_messages.build(
      user: current_user,
      content: params[:content]
    )

    if message.save
      render json: format_message(message), status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def format_message(msg)
    {
      id: msg.id,
      content: msg.content,
      user_id: msg.user_id,
      username: msg.user.username,
      message_type: msg.message_type || 'message',
      metadata: msg.metadata ? JSON.parse(msg.metadata) : nil,
      created_at: msg.created_at,
      updated_at: msg.updated_at
    }
  end
end

