module ControllerHelpers
  def login_customer
    @request.env["devise.mapping"] = Devise.mappings[:account]
    customer = Customer.first || FactoryGirl.create(:customer) 
    auth_headers = customer.create_new_auth_token
    request.headers.merge! auth_headers
    customer
  end

  def login_merchant
    @request.env["devise.mapping"] = Devise.mappings[:account]
    merchant = Merchant.first || FactoryGirl.create(:merchant)
    auth_headers = merchant.create_new_auth_token 
    request.headers.merge! auth_headers
    merchant
  end

  def omniauth_register_account
    FactoryGirl.create :customer, uid: '123', provider: 'wechat'
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

  def generate_wechat_text_message(content)
    file = File.open Rails.root.join('test/fixtures/wechat_post_text')
    file.read.sub 'STUB', content
  end
end
