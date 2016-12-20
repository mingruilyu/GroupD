module SpecHelpers
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
    account = FactoryGirl.create :customer, uid: '123', provider: 'wechat'
    account.create_new_auth_token
    account
  end

  def request_register_account
    post '/auth', username: 'david', email: 'david@gmail.com', 
      password: '12345678', password_confirmation: '12345678',
      type: Account::ACCOUNT_TYPE_MERCHANT
  end

  def register_account
    merchant = FactoryGirl.create :merchant
    merchant
  end

  def confirm_account(account)
    account.update_attribute :confirmed_at, Time.now
  end

  def login_account(account)
    account.create_new_auth_token
  end

  def get_token_from_response(response)
    header = response.header
    {
      :'access-token'=>     header['access-token'],
      'client' =>           header['client'],
      'uid' =>              header['uid']
    }
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

  def concurrency_test(concurrency_level, &block)
    if block_given?
      concurrency_level.times do |i|
        puts "Forking Process #{i}"
        fork_with_new_connection i, &block
      end
      Process.waitall
    end
  end

  def fork_with_new_connection(number, &block)
    config = ActiveRecord::Base.remove_connection
    fork do
      begin
        ActiveRecord::Base.establish_connection(config)
        block.call number
      ensure
        ActiveRecord::Base.remove_connection
        Process.exit!
      end
    end
    ActiveRecord::Base.establish_connection(config)
  end

  def delay_random_time
    sleep (rand(0..50) / 100.0)
  end

  class GlobalStore
    def initialize
      @read, @write = IO.pipe
    end

    def write(data)
      @write.puts data
    end

    def read
      @write.close
      data = @read.read
      @read.close
      data
    end
  end
end
