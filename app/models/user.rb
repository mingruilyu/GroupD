class User < ActiveRecord::Base
	belongs_to :city

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, 
				 :validatable, :authentication_keys => {login: true}

	validates :cellphone_id, uniqueness: true, presence: true

  def login=(login)
		@login = login
	end

	def login
		@login #|| self.cellphone_id || self.email
	end

	def self.find_for_database_authentication(warden_conditions)
		conditions = warden_conditions.dup
		login = conditions.delete(:login)

		# if login is in form of an email address, we always use it as email login
		# regardless if user want to use it as username
		if login =~ /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/
			where(conditions).where(["email = :value", { :value => login }]).first
		else
			where(conditions).where(["cellphone = :value", { :value => login }]).first
		end
	end
	
	def login=(login)
		@login = login
	end

	def login
		@login || self.cellphone || self.email
	end

	def cellphone_should_be_valid
		if cellphone !~ /^1?\d{10}$/
			errors.add(:cellphone, "Please provide a valid cellphone number!")			
		end
	end
end
