require 'securerandom'
class Cellphone < ActiveRecord::Base
  validates :number, presence: true, uniqueness: true, number: true

  CONFIRMATION_LIFESPAN = 200

  def sanitize(id)
    Cellphone.find id
  end

  def has_confirmation_expired?
    return (Time.now.utc - self.confirmation_sent_at) > CONFIRMATION_LIFESPAN
  end

  def has_confirmed?
    return self.confirmed_at.present?
  end

  def verify?(token)
    return confirmation_token == token
  end

  def verify!
    self.update_attribute(:confirmed_at, Time.now.utc)
  end
  
  def generate_cellphone_confirmation_token
    token = ""
    CONFIRMATION_TOKEN_LENGTH.times do
      token << SecureRandom.random_number(10).to_s
    end
    puts "TOKEN GENERATED IS: " + token
    self.confirmation_token = token
    self.confirmation_sent_at = Time.now.utc
  end

  private

    CONFIRMATION_TOKEN_LENGTH = 6
    US_AREA_CODE = '1'
    US_CELLPHONE_NUMBER_LENGTH = 11 # with area code

end
