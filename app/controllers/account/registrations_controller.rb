class Account::RegistrationsController < Devise::RegistrationsController
  def create
    super do
      type = session[:type]
      session.delete(:type)
      resource.update_attribute(:type, type)
    end
  end
end
