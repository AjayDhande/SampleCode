class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  layout :layout
  respond_to :html

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  self.responder = FrontendResponder

  include Paginable
  include Searchable
  include Pundit

  helper_method :current_order

  def current_order
    if session[:order_id].present? && Order.exists?(id: session[:order_id], complete: false)
      Order.find(session[:order_id])
    else
      order = Order.new
    end           
  end

  def change_country_code
    @country_mob_code = ISO3166::Country[params[:country_code]].country_code
    render json: {country_code_mob: @country_mob_code}
  end

  def getdate
    render json: {today_date: "#{Time.now.strftime('%Y/%m/%d %H:%M:%S')}"}
  end

  protected

    def self.authenticated!(options = {})
      before_action :authenticate_user!, options
    end

    def authorized(collection)
      policy_scope collection
    end

    def layout
      if params[:controller].include? 'admin'
        'admin'
      elsif use_nav_layout?
        'nav'
      else
        'application'
      end
    end

    def use_nav_layout?
      true
    end
    helper_method :use_nav_layout?

  private
    def user_not_authorized
      flash[:alert] = I18n.t('flash.errors.not_authorized')
      redirect_to(request.referrer || root_path)
    end
end
