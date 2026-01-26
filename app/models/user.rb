class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         :validatable, authentication_keys: [:login]

  attr_writer :login

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true

  def generate_temporary_authentication_token
    token = Devise.friendly_token
    tokens = (self.tokens || []).push(token)
    self.update(tokens: tokens)
    return token
  end

  def clear_temporary_authentication_token
    self.authentication_token = nil
    self.save
  end

  def login
    @login || self.username || self.email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["username = :value OR lower(email) = lower(:value)", { :value => login }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  has_many :chat_rooms_as_user1, class_name: 'ChatRoom', foreign_key: 'user1_id'
  has_many :chat_rooms_as_user2, class_name: 'ChatRoom', foreign_key: 'user2_id'
  has_many :chat_messages
  has_many :lobby_entries

  def chat_rooms
    ChatRoom.where("user1_id = ? OR user2_id = ?", id, id)
  end
end
