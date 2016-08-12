module ControllerHelpers
  def login_customer
    @request.env["devise.mapping"] = Devise.mappings[:account]
    sign_in FactoryGirl.create(:customer)
  end

  def login_merchant
    @request.env["devise.mapping"] = Devise.mappings[:account]
    sign_in FactoryGirl.create(:merchant)
  end
end
