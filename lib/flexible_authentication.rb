module FlexibleAuthentication
  def login=(login)
    @login = login
  end

	def login
    @login
  end
  module AuthenticableOverride
    # methods override database_authenticable
  	def find_for_database_authentication(warden_conditions)
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
  end

  def self.included(including_class)
    including_class.extend AuthenticableOverride
  end
end
