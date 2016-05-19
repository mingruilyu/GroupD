class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
	before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_cart

  protected

  	def configure_permitted_parameters
  		devise_parameter_sanitizer.for(:sign_in) { |user|
  			user.permit(:login, :username, :email, :password, :remember_me)
  		}
  
  		devise_parameter_sanitizer.for(:sign_up) { |user|
  			user.permit(:username, :email, :cellphone_id, :password, 
  				:password_confirmation, :remember_me)
  		}
  
  		devise_parameter_sanitizer.for(:account_update) { |user|
  			user.permit(:username, :email, :password, 
  				:password_confirmation, :current_password)
  		}
  	end

    def current_cart
      if session[:cart_id].present?
        # there is a cart in the current session and has not been checked out
        Cart.find(session[:cart_id])
      elsif current_user.present?
        # a user session starts, retrieve the user's unchecked cart in 
        # last session
        cart = Cart.find_by_user_id_and_status!(current_user.id, 
                                               Cart::UNCHECKOUTED)
        session[:cart_id] = cart.id
        cart
      else
        # a guest session starts. create a new cart
        cart = Cart.create(user_id: User::GUEST_USER_ID)
        session[:cart_id] = cart.id
        cart
      end
    rescue ActiveRecord::RecordNotFound
        # exception happens when the user does not have any unchecked cart 
        # in the last session
        cart = Cart.create(user_id: current_user.id)
        session[:cart_id] = cart.id
        cart
    end  

  private

    def after_sign_in_path_for(resource)
      if resource_name == :user
        root_path
      else
        merchant_path(current_merchant)
      end
    end

  
end
