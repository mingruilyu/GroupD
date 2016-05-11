module CellphonesHelper
  def new_registration_path
    return session[:type] == 'users' ? new_user_registration_path
    : new_merchant_registration_path
  end
end
