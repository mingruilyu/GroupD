class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

	before_action :configure_permitted_parameters, if: :devise_controller?

  before_filter :check_address_configuration

  helper_method :current_cart
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

    def current_cart
      if session[:cart_id].present?
        # there is a cart in the current session and has not been checked out
        Cart.find(session[:cart_id])
      elsif account_signed_in?
        # a user session starts, retrieve the user's unchecked cart in 
        # last session
        cart = Cart.find_by_account_id_and_status!(current_account.id, 
                                               Cart::UNCHECKOUTED)
        session[:cart_id] = cart.id
        cart
      else
        # a guest session starts. create a new cart
        cart = Cart.create(account_id: Customer::GUEST_USER_ID)
        session[:cart_id] = cart.id
        cart
      end
    rescue ActiveRecord::RecordNotFound
        # exception happens when the user does not have any unchecked cart 
        # in the last session
        cart = Cart.create(account_id: current_account.id)
        session[:cart_id] = cart.id
        cart
    end  

    def is_guest?
      not account_signed_in?
    end

  private

    def after_sign_in_path_for(resource)
      if resource.is_customer?
        root_path
      else
        merchant_path(current_account)
      end
    end

    def check_address_configuration
      if account_signed_in? and current_account.is_customer? and current_account.building_id.nil?
        redirect_to add_address_customer_path(current_account) 
      end
    end
end
