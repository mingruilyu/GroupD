class Payment < ActiveRecord::Base
  belongs_to :customer

  validates :method, presence: true, uniqueness: { scope: :customer }
  validates :payment_type, numericality: { in: [0, 1, 2, 3] }

  validates_associated :customer

  TYPE_RECORD_CASH_PAYMENT = 'Record'
  TYPE_CREDIT_CARD = 'Credit'
  TYPE_DEBI_CARD = 'Debi'
  TYPE_PAYPAL = 'Paypal'

  RECORD_CASH_ID = 0

  def self.record_cash
    Payment.new(id: RECORD_CASH_ID, 
      payment_type: TYPE_RECORD_CASH_PAYMENT)
  end

  def type_method
    "#{self.payment_type} #{self.method}"
  end

  def self.type_options
    type = []
    type.push([TYPE_CREDIT_CARD, TYPE_CREDIT_CARD])
      .push([TYPE_DEBI_CARD, TYPE_DEBI_CARD])
      .push([TYPE_PAYPAL, TYPE_PAYPAL])
    type
  end

end
