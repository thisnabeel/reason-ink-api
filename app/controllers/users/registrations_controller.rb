# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :authenticate_user_from_token!, only: [:create]
  # POST /resource
  def create
    user = User.new(user_params)
    
    if user.save
      generated_token = user.generate_temporary_authentication_token
      render json: user.attributes.merge(generated_token: generated_token), status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :username)
  end
end

