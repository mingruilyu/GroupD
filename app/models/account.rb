class Account < ActiveRecord::Base

  ACCOUNT_TYPE_CUSTOMER = 'Customer'
  ACCOUNT_TYPE_MERCHANT = 'Merchant'
  GUEST_CELLPHONE_ID    = 0
  GUEST_USERNAME        = 'guest'

  belongs_to :cellphone
  has_many :orders
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, 
         :validatable, :authentication_keys => { login: true }

  validates :cellphone_id, uniqueness: true, presence: true
  validates_associated :cellphone

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

  def self.guest_email
    "guest_#{Time.now.to_i}#{rand(100)}@dpool.com"
  end

  # methods override database_authenticable
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)

  	# if login is in form of an email address, we always use it as email login
    # regardless if user want to use it as username
    if login =~ /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/
      puts "FIND_FOR_DATABASE_AUTHENTICATION"
      where(conditions).where(["email = :value", { :value => login }]).first
    else
      joins(:cellphone).where(conditions)
      .where("cellphones.number = :number", { number: login }).first
  	end
  end

  class NotAuthorized < StandardError
  end
end
