class ApplicationController < ActionController::Base
  include Filter
  include ExceptionHandler

  rescue_from Exceptions::NotAuthorized, with: :unauthorized
  rescue_from ActionController::UnknownFormat, with: :not_found
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request

  protect_from_forgery with: :null_session

  before_action :request_format_filter 
	before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  	def configure_permitted_parameters
  		devise_parameter_sanitizer.for :sign_in  do |account|
  			account.permit :login, :username, :email, :password, :remember_me
      end
  
  		devise_parameter_sanitizer.for :sign_up do |account|
  			account.permit :username, :email, :cellphone_id, :password, 
  				:password_confirmation, :remember_me
      end
  
  		devise_parameter_sanitizer.for :account_update do |account|
  			account.permit :username, :email, :password, 
  				:password_confirmation, :current_password
      end
  	end

    def current_order
      if account_signed_in? && session[:order].present?
        # there is an order in the current session and has not been
        # checked out
        @order ||= Order.includes(:order_items).find(session[:order])
      elsif account_signed_in?
        # account just logged in.
        @order = Order.includes(:order_items).find_by_customer_id_and_status(
          current_account.id, Order::STATUS_UNCHECKOUT)
        if @order.nil?
          # the account does not have any order that has not been checked out. 
          # out.
          @order = Order.create(customer_id: current_account.id)
        end
        session[:order] = @order.id
        @order
      end
    end  

  private

    def after_sign_in_path_for(resource)
      if resource.is_customer?
        root_path
      else
        merchant_path(current_account)
      end
    end
end


