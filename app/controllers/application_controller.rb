class ApplicationController < ActionController::API
  before_action :authenticate_user_from_token!

  private

  def authenticate_user_from_token!
    # Skip if no auth headers (for public endpoints)
    return unless request.headers['X-User-Email'].present? && request.headers['X-User-Token'].present?

    user = User.find_by(email: request.headers['X-User-Email'])
    token = request.headers['X-User-Token']

    if user.present? && user.tokens.present? && user.tokens.include?(token)
      @current_user = user
    else
      head(:unauthorized)
    end
  end

  def current_user
    @current_user
  end
end
