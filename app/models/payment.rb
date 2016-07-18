class Payment < ActiveRecord::Base
  belongs_to :account

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
