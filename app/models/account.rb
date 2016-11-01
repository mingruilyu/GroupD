class Account < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User

  ACCOUNT_TYPE_CUSTOMER = 'Customer'
  ACCOUNT_TYPE_MERCHANT = 'Merchant'
  GUEST_CELLPHONE_ID    = 0
  GUEST_USERNAME        = 'guest'

  belongs_to :cellphone
  has_many :orders
  
  def login=(login)
    @login = login
  end

	def login
    @login
  end

  def is_customer?
      type == Account::ACCOUNT_TYPE_CUSTOMER
  end

  def is_merchant?
      type == Account::ACCOUNT_TYPE_MERCHANT
  end

  def self.omniauth_register(auth_hash={})
    account = Account.where(uid: auth_hash[:uid], 
      provider: auth_hash[:provider]).first_or_initialize
    if account.new_record?
      account.set_account_default auth_hash
    end

    # sync user info with provider
    if auth_hash[:info].present?
      account.assign_provider_attrs auth_hash
    end

    # update/generate auth token
    account.update_auth_token

    account.save!
  end

  # methods override database_authenticable
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)

  	# if login is in form of an email address, we always use it as email login
    # regardless if user want to use it as username
    if login =~ /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/
      where(conditions).where(["email = :value", { :value => login }]).first
    else
      joins(:cellphone).where(conditions)
      .where("cellphones.number = :number", { number: login }).first
  	end
  end

  def assign_provider_attrs(auth_hash)
    self.assign_attributes({
      username: auth_hash[:info][:username],
      name:     auth_hash[:info][:name],
      image:    auth_hash[:info][:image],
      email:    auth_hash[:info][:email]
    })
  end

  def set_account_default(auth_hash)
    password = SecureRandom.urlsafe_base64 nil, false
    self.password = password
    self.password_confirmation = password
    self.email = "#{auth_hash[:uid]}@#{auth_hash[:provider]}.com"
    self.type = auth_hash[:type]
    self.username ||= "#{auth_hash[:provider]}_#{auth_hash[:uid]}"
  end

  def update_auth_token
    client_id = SecureRandom.urlsafe_base64 nil, false
    token     = SecureRandom.urlsafe_base64 nil, false
    expiry    = (Time.now + DeviseTokenAuth.token_lifespan).to_i
    
    self.tokens[client_id] = {
      token: (BCrypt::Password.create token), 
      expiry: expiry
    }
  end

  def as_json(options={})
    super except: [:created_at, :updated_at, :uid, :provider, 
      :coordinate_id]
  end

  protected
    def active_for_authentication?
      self.cellphone_id.present?
    end

    def confirmation_required?
      self.provider == 'email' && !confirmed?
    end
end
