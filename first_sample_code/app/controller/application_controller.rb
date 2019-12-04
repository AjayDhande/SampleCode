class ApplicationController < ActionController::Base
require 'active_support/core_ext/string'
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :set_locale
  layout :select_layout
  before_action :configure_permitted_parameters, if: :devise_controller?

  def index
    @collection = model
  end

 protected
    # Defines the layout to use
    def select_layout
      user_signed_in? ? 'application' : 'external'
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:accept_invitation, keys: [:first_name, :last_name])
    end
  private
    def set_locale
      I18n.locale = session[:locale] || I18n.default_locale
      session[:locale] = I18n.locale
    end
end
