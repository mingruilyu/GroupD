class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

	before_action :configure_permitted_parameters, if: :devise_controller?

  before_filter :check_address_configuration, unless: :devise_controller?

  helper_method :current_dish_cart
  helper_method :current_combo_cart
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

    def current_dish_cart
      current_cart :dish
    end

    def current_combo_cart
      current_cart :combo
    end

    def current_cart(cart_name)
      cart_name = cart_name == :combo ? :combo_cart_id : :dish_cart_id
      if session[cart_name].present?
        # there is a cart in the current session and has not been checked out
        Cart.includes(:cart_items).find(session[cart_name])
      elsif account_signed_in?
        # a user session starts, retrieve the user's unchecked cart in 
        # last session
        cart = Cart.includes(:cart_items).find_by_account_id_and_status!(
          current_account.id, Cart::UNCHECKOUTED)
        session[cart_name] = cart.id
        cart
      else
        # a guest session starts. create a new cart
        cart = Cart.create(account_id: current_or_guest_account.id)
        session[cart_name] = cart.id
        cart
      end
    rescue ActiveRecord::RecordNotFound
        # exception happens when the user does not have any unchecked cart 
        # in the last session
        cart = Cart.create(account_id: current_or_guest_account.id)
        session[cart_name] = cart.id
        cart
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
        redirect_to add_address_customer_path(current_or_guest_account)
      end
    end

    
end
