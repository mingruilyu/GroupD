class User < ActiveRecord::Base
	belongs_to :city
  belongs_to :cellphone
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, 
				 :validatable, :authentication_keys => {login: true}

	validates :cellphone_id, uniqueness: true, presence: true

  include FlexibleAuthentication

end
