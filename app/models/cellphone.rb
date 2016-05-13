class Cellphone < ActiveRecord::Base
  before_validation do
   self.number = self.class.strip_area_code(self.number) 
  end

  validates :number, presence: true, uniqueness: true
  validate :number_should_be_valid

  CONFIRMATION_LIFESPAN = 200

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
  
  def self.strip_area_code(number)
    number.length == US_CELLPHONE_NUMBER_LENGTH \
      && number[0] == US_AREA_CODE ? 
      number[US_AREA_CODE.length..-1] : number
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

    def number_should_be_valid
      if number.length != 10
        errors.add(:number, I18n.t('error.INVALID_NUMBER'))
      end
    end
    
   
end
