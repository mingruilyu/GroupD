require './lib/framework/controller_helper'
class ApplicationController < ActionController::Base
  include ControllerHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

	before_action :configure_permitted_parameters, if: :devise_controller?

  before_filter :check_address_configuration, if: :should_check_address? 

  helper_method :current_cart
  helper_method :current_or_guest_account
  helper_method :is_guest?

  protected

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

    def check_signed_in
      unless account_signed_in?
        # store the previous path
        session[:last_path] ||= request.referer
        render js: "$('#signin_modal').modal()"
      end
    end

    def current_or_guest_account
      if current_account
        if session[:guest_account_id] \
            && session[:guest_account_id] != current_account.id
          logging_in_guest
          # reload guest_user to prevent caching problems before destruction
          guest_account.reload.try(:destroy)
          session[:guest_account_id] = nil
        end
        current_account
      else
        guest_account
      end
    end

    def guest_account(with_retry = true)
      @cached_guest_account ||= Account.find(session[:guest_account_id]\
                                             ||= create_guest_account.id)
    rescue ActiveRecord::RecordNotFound
      session[:guest_account_id] = nil
      guest_account if with_retry
    end

    def create_guest_account
      account = Account.create(
        username: Account::GUEST_USERNAME,
        email:    Account.guest_email,
        cellphone_id: Account::GUEST_CELLPHONE_ID,
        type:     Account::ACCOUNT_TYPE_CUSTOMER
      )
      account.save!(validate: false)
      session[:guest_account_id] = account.id
      account
    end

    def logging_in_guest
      # Todo sync the guest cart 
    end

    def current_cart
      if account_signed_in? && session[:cart].present?
        # there is a cart in the current session and has not been
        # checked out
        @cart ||= Cart.includes(:cart_items).find(session[:cart])
      elsif account_signed_in?
        # account just logged in.
        @cart = Cart.includes(:cart_items).find_by_account_id_and_status(
          current_account.id, Cart::STATUS_UNCHECKOUT)
        if @cart.nil?
          # the account does not have any cart that has not checked 
          # out. use the previous guest cart.
          @cart = Cart.create(account_id: current_account.id)
        end
        session[:cart] = @cart.id
        @cart
      elsif session[:cart].present?
        # there is a guest cart in the current session.
        @cart ||= Cart.includes(:cart_items).find(session[:cart])
      else
        # a guest session starts. create a new cart
        @cart = Cart.create(account_id: current_or_guest_account.id)
        session[:cart] = @cart.id
        @cart
      end
    end  

  private

    def is_guest?
      not account_signed_in?
    end

    def after_sign_in_path_for(resource)
      if resource.is_customer?
        if session[:last_path].present?
          path = session[:last_path]
          session.delete(:last_path)
          path
        else
          root_path
        end
      else
        merchant_path(current_account)
      end
    end

    def check_address_configuration
      if current_or_guest_account.is_customer? && current_or_guest_account.building_id.nil?
        redirect_to edit_customer_address_path(current_or_guest_account)
      end
    end

    
end
