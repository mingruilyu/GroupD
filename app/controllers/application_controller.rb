class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
	before_action :configure_permitted_parameters, if: :devise_controller?

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
    
    private
        def current_menu
            Menu.find(session[:menu_id])
        rescue ActiveRecord::RecordNotFound
            menu = Menu.create
            session[:menu_id] = menu.id
            menu
        end
  
  def after_sign_in_path_for(resource)
    if resource_name == :user
      root_path
    else
      merchant_path
    end
  end

end
