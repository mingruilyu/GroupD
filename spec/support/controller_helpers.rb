module ControllerHelpers
  def login_customer
    @request.env["devise.mapping"] = Devise.mappings[:account]
    sign_in FactoryGirl.create(:customer)
  end

  def login_merchant
    @request.env["devise.mapping"] = Devise.mappings[:account]
    sign_in (Merchant.first || FactoryGirl.create(:merchant))
  end

  def generate_json_list(objects)
    json_list = []
    objects.each do |object|
      json_list.append object.as_json.stringify_keys
    end
    json_list
  end

  def generate_json_msg(level, msgno)
    msg = {}
    msg['level'] = level.to_s
    msg['msgno'] = msgno 
    msg
  end
end
