class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  include Pundit
  impersonates :user
  # Pundit dev config:
  # after_action :verify_authorized, except: [:index]
  # after_action :verify_policy_scoped, only: :index

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def error_messages(errors)
    errors.full_messages.map { |msg| msg }.join('; ')
  end

  def highlight(value)
    value.yield_self { |s| '<span class="highlighted">%s</span>' % s }
  end

  def scrub_params(type, field)
    params[type].delete(field) if params[type][field].blank?
  end

  private

  def user_not_authorized
    flash[:alert] = t('user.unauthorized')
    redirect_to(request.referrer || root_path)
  end
end
