class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Filter
  include ExceptionHandler

#  rescue_from StandardError, with: :internal_server_error
#=begin
  rescue_from ActiveRecord::RecordInvalid, with: :bad_request
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ActionControllerError, with: :bad_request
  rescue_from ActionController::UnknownFormat, with: :not_found
  rescue_from Exceptions::StaleRecord, with: :gone
  rescue_from Exceptions::NotEffective, with: :found
  rescue_from Exceptions::BadParameter, with: :bad_request
  rescue_from Exceptions::NotAuthorized, with: :unauthorized
  rescue_from Exceptions::FileOversize, with: :bad_request
#=end
  protect_from_forgery with: :null_session

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
        @current_order ||= Order.includes(:order_items).find(session[:order])
      elsif account_signed_in?
        # account just logged in.
        @current_order = Order.includes(:order_items).find_by_customer_id_and_status(
          current_account.id, Order::STATUS_UNCHECKOUT)
        if @current_order.nil?
          # the account does not have any order that has not been checked out. 
          # out.
          @current_order = Order.create(customer_id: current_account.id)
        end
        session[:order] = @current_order.id
        @current_order
      end
    end  
end


