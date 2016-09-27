class Transaction < ActiveRecord::Base
  TYPE_PAYMENT = 0
  TYPE_DEPOSIT = 1
  TYPE_REFUND = 2
end
