class Debt < ActiveRecord::Base
  belongs_to :customer, foreign_key: 'debtor_id'
  belongs_to :merchant, foreign_key: 'loaner_id'

  STATUS_SETTLED = true
  STATUS_UNSETTLED = false

  # loaner is always merchant while debtor is always customer.
  # when amount goes to negative, customer has deposit.

  scope :by_loaner, ->(loaner) { where(loaner_id: loaner) }
  scope :by_debtor, ->(debtor) { where(debtor_id: debtor) }

  def self.add_debt(loaner, debtor, amount)
    debt = Debt.find_by_loaner_id_and_debtor_id(loaner, debtor)
    if debt.nil?
      Debt.create(loaner_id: loaner, debtor_id: debtor, amount: amount)
    else
      debt.update_attribute(:amount, debt.amount + amount)
    end
  end
end
