require 'securerandom'
class Cellphone < ActiveRecord::Base
  validates :number, presence: true, uniqueness: { message: I18n.t('error.NUMBER_USED') }, number: true

  CONFIRMATION_LIFESPAN = 200
  MIN_CONFIRMATION_SEND_INVERTAL = 60
  CONFIRMATION_TOKEN_LENGTH = 6

  def self.create_cellphone(number, account_id)
    cellphone = Cellphone.new account_id: account_id, number: number
    cellphone.send_confirmation
    cellphone.save!
    cellphone.confirmation_token
  end

  def send_confirmation
    self.generate_cellphone_confirmation_token
  end

  def resend_confirmation
    if self.confirmation_sent_at + \
      MIN_CONFIRMATION_SEND_INVERTAL.second > Time.now
      self.errors[:confirm] = I18n.t 'error.RESEND_TOO_FREQUENTLY'
      raise Exceptions::NotEffective.new(self)
    elsif self.has_confirmed?
      self.errors[:confirm] = I18n.t 'error.DUPLICATE_CONFIRMATION'
      raise Exceptions::NotEffective.new(self)
    end
    return self.generate_cellphone_confirmation_token
  end

  def verify_token(token, account)
    if self.has_confirmed?
      errors = I18n.t 'error.DUPLICATE_CONFIRMATION'
    elsif self.has_confirmation_expired? 
      errors = I18n.t 'error.CONFIRMATION_EXPIRED'
    elsif !self.token_valid? token
      errors = I18n.t 'error.WRONG_TOKEN'
    end
    unless errors.nil?
      self.errors[:confirm] = errors
      raise Exceptions::NotEffective.new(self)
    end
    Cellphone.transaction do
      self.verify!
      account.update_attribute :cellphone_id, self.id
    end
  end

  def has_confirmation_expired?
    return (self.confirmation_sent_at +
      CONFIRMATION_LIFESPAN.second) < Time.now
  end

  protected

    def has_confirmed?
      return self.confirmed_at.present?
    end

    def token_valid?(token)
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
end
