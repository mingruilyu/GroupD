class Users::SessionsController < Devise::SessionsController
 before_filter :check_cellphone_confirmation, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
private
  def check_cellphone_confirmation
    puts "CHEKCING CONFIRMATION"
    unless current_user.confirmed_at
      redirect_to confirmations_new_path
    end
  end
end
