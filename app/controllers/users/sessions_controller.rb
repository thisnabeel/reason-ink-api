# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_user_from_token!, only: [:create]
  # POST /resource/sign_in
  def create 
    user = User.find_by(email: params[:login]) || User.find_by(username: params[:login])

    if user.present? && user.valid_password?(params[:password])
      generated_token = user.generate_temporary_authentication_token
      render json: user.attributes.merge(generated_token: generated_token)
    else
      head(:unauthorized)
    end
  end

  # DELETE /resource/sign_out
  def destroy
    if request.headers['X-User-Token'].present?
      user = User.find_by(email: request.headers['X-User-Email'])
      token = request.headers['X-User-Token']
      if user.present?
        user.update(tokens: (user.tokens || []) - [token])
        render json: { message: 'Signed out successfully' }
      else
        head(:unauthorized)
      end
    else
      head(:unauthorized)
    end
  end

  private
  def respond_to_on_destroy
    head :no_content
  end
end

