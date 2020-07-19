# frozen_string_literal: true

class SitesController < ApplicationController
  def home
    skip_authorization
    skip_policy_scope
  end
end
