class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  include Pundit
  impersonates :user
  # Pundit dev config:
  # after_action :verify_authorized, except: [:index]
  # after_action :verify_policy_scoped, only: :index
end
