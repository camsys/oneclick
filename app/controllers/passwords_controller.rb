class PasswordsController < Devise::PasswordsController
  before_filter :validate_reset_password_token, only: :edit

  private

  def validate_reset_password_token
    token = Devise.token_generator.digest(User, :reset_password_token, params[:reset_password_token])
    recoverable = resource_class.find_by_reset_password_token(token)
    unless (recoverable && recoverable.reset_password_period_valid?)
      redirect_to root_path, :alert => "Invalid password reset token"
    end
  end

end
