module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user_id
  end

  def current_user_id
    clerk&.user_id
  end

  def require_user!
    return if current_user_id.present?

    redirect_to sign_in_path, alert: "Sign in to vote on events."
  end

  private

  def command_bus
    Rails.configuration.command_bus
  end
end
