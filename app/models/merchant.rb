class Merchant < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :authentication_keys => {login: true}
  has_one :restaurant
  belongs_to :cellphone

  validates :cellphone_id, uniqueness: true, presence: true

  include FlexibleAuthentication
end
