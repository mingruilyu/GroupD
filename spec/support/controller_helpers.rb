module ControllerHelpers
  def login_customer
    @request.env["devise.mapping"] = Devise.mappings[:account]
    customer = FactoryGirl.create(:customer) 
    auth_headers = customer.create_new_auth_token
    request.headers.merge! auth_headers
    #sign_in FactoryGirl.create(:customer)
  end

  def login_merchant
    @request.env["devise.mapping"] = Devise.mappings[:account]
    merchant = Merchant.first || FactoryGirl.create(:merchant)
    #sign_in ()
    auth_headers = merchant.create_new_auth_token 
    request.headers.merge! auth_headers
  end

  def generate_json_list(objects)
    json_list = []
    objects.each do |object|
      json_list.append object.as_json.stringify_keys
    end
    json_list
  end

  def generate_json_msg(level, message)
    msg = {}
    msg['level'] = level.to_s
    msg['message'] = message.as_json
    msg
  end
end
