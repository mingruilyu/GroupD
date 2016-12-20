class Customers::CustomerController < WebApplicationController
  before_action :authenticate_account!                   
  before_action :params_sanitization
  before_action :authorization
  before_action :cellphone_configuration
  before_action :address_configuration
end
