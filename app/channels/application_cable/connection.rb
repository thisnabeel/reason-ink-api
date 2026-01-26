module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # Try headers first (for HTTP upgrade)
      user_email = request.headers['X-User-Email']
      user_token = request.headers['X-User-Token']
      
      # Fall back to query params (for WebSocket connections)
      if user_email.blank? || user_token.blank?
        user_email = request.params['user_email']
        user_token = request.params['user_token']
      end

      if user_email && user_token
        user = User.find_by(email: user_email)
        if user && user.tokens.present? && user.tokens.include?(user_token)
          user
        else
          reject_unauthorized_connection
        end
      else
        reject_unauthorized_connection
      end
    end
  end
end

