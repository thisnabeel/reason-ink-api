class ChatRoomsController < ApplicationController
  before_action :authenticate_user_from_token!

  def index
    # Get all open rooms (waiting or active) that the user can see
    open_rooms = ChatRoom.where(status: ['waiting', 'active'])
                        .includes(:chatroomable, :user1, :user2)
                        .order(created_at: :desc)
    
    render json: open_rooms.map { |room| format_chat_room(room, current_user) }
  end

  def show
    chat_room = ChatRoom.find(params[:id])
    
    unless chat_room.participants.include?(current_user)
      return head(:forbidden)
    end

    render json: format_chat_room(chat_room, current_user)
  end

  def create
    chatroomable_type = params[:chatroomable_type]
    chatroomable_id = params[:chatroomable_id]
    
    chatroomable = chatroomable_type.constantize.find(chatroomable_id)
    
    chat_room = ChatRoom.new(
      chatroomable: chatroomable,
      user1: current_user,
      status: 'waiting'
    )

    if chat_room.save
      render json: format_chat_room(chat_room, current_user), status: :created
    else
      render json: { errors: chat_room.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def fetch_random_experiment
    chat_room = ChatRoom.find(params[:id])
    
    unless chat_room.participants.include?(current_user)
      return head(:forbidden)
    end

    # Get a random experiment
    random_experiment = Experiment.order('RANDOM()').first
    
    if random_experiment
      chat_room.update(current_experiment: random_experiment)
      
      # Create a system message about the experiment change
      system_message = chat_room.chat_messages.create!(
        user: current_user,
        content: "📚 Experiment loaded: #{random_experiment.title}",
        message_type: 'experiment_change',
        metadata: {
          experiment_id: random_experiment.id,
          experiment_title: random_experiment.title,
          experiment_body: random_experiment.body
        }.to_json
      )

      # Broadcast the experiment change to all participants
      # This will be received by both users via WebSocket
      ChatChannel.broadcast_to(chat_room, {
        type: 'experiment_change',
        id: system_message.id,
        content: system_message.content,
        user_id: system_message.user_id,
        username: system_message.user.username,
        message_type: system_message.message_type,
        metadata: system_message.metadata ? JSON.parse(system_message.metadata) : nil,
        created_at: system_message.created_at,
        experiment: {
          id: random_experiment.id,
          title: random_experiment.title,
          body: random_experiment.body
        }
      })

      render json: {
        experiment: {
          id: random_experiment.id,
          title: random_experiment.title,
          body: random_experiment.body
        }
      }
    else
      render json: { error: 'No experiments available' }, status: :not_found
    end
  end

  private

  def format_chat_room(room, current_user = nil)
    is_host = current_user && (room.user1_id == current_user.id)
    can_join = current_user && room.user2.nil? && !is_host
    
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
        username: room.user1.username,
        email: room.user1.email
      },
      user2: room.user2 ? {
        id: room.user2.id,
        username: room.user2.username,
        email: room.user2.email
      } : nil,
      status: room.status,
      is_host: is_host,
      can_join: can_join,
      participant_count: room.user2 ? 2 : 1,
      current_experiment: room.current_experiment ? {
        id: room.current_experiment.id,
        title: room.current_experiment.title,
        body: room.current_experiment.body
      } : nil,
      created_at: room.created_at,
      updated_at: room.updated_at
    }
  end

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

