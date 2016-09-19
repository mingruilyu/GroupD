require './lib/framework/response'
require './lib/framework/controller_helper'
class ApplicationController < ActionController::Base
  include ControllerHelper
  include Filter
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :check_request_format
	before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_cart
  helper_method :current_or_guest_account
  helper_method :is_guest?

  protected

    def bad_request_path
      '/public/400.html'
    end

    def not_found_path
      '/public/404.html'
    end

  	def configure_permitted_parameters
  		devise_parameter_sanitizer.for(:sign_in) { |account|
  			account.permit(:login, :username, :email, :password, :remember_me)
  		}
  
  		devise_parameter_sanitizer.for(:sign_up) { |account|
  			account.permit(:username, :email, :cellphone_id, :password, 
  				:password_confirmation, :remember_me)
  		}
  
  		devise_parameter_sanitizer.for(:account_update) { |account|
  			account.permit(:username, :email, :password, 
  				:password_confirmation, :current_password)
  		}
  	end

    def current_cart
      if account_signed_in? && session[:cart].present?
        # there is a cart in the current session and has not been
        # checked out
        @cart ||= Cart.includes(:cart_items).find(session[:cart])
      elsif account_signed_in?
        # account just logged in.
        @cart = Cart.includes(:cart_items).find_by_customer_id_and_status(
          current_account.id, Cart::STATUS_UNCHECKOUT)
        if @cart.nil?
          # the account does not have any cart that has not checked 
          # out. use the previous guest cart.
          @cart = Cart.create(customer_id: current_account.id)
        end
        session[:cart] = @cart.id
        @cart
      elsif session[:cart].present?
        # there is a guest cart in the current session.
        @cart ||= Cart.includes(:cart_items).find(session[:cart])
      else
        # a guest session starts. create a new cart
        @cart = Cart.create(customer_id: current_or_guest_account.id)
        session[:cart] = @cart.id
        @cart
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
