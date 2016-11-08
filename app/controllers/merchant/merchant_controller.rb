class Merchant::MerchantController < WebApplicationController
  before_action :authenticate_account!
  before_action :params_sanitization
  before_action :authorization
  before_action :cellphone_configuration
end
