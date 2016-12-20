class Debt < ActiveRecord::Base
  belongs_to :customer, foreign_key: 'debtor_id'
  belongs_to :merchant, foreign_key: 'loaner_id'

  #validates :loaner_id, uniqueness: { scope: :debtor_id }

  # loaner is always merchant while debtor is always customer.
  # when amount goes to negative, customer has deposit.

  scope :by_loaner, ->(loaner) { where(loaner_id: loaner) }
  scope :by_debtor, ->(debtor) { where(debtor_id: debtor) }

  def self.add_debt(loaner, debtor, amount)
    # The uniqueness of (loaner, debtor) is guaranteed through
    # database contraint.
    debt = nil
    begin
      ActiveRecord::Base.transaction do
        # The lock here is still necessary, think of the following 
        # scenario:
        #   Process A update amount in a trx before Process B does, 
        #   however, A is rolled back for some reason. If not locked,
        #   the final result would be the sum of A + B.
        debt = Debt.find_or_create_by loaner_id: loaner, 
          debtor_id: debtor
        debt.lock!
        debt.update_attribute :amount, debt.amount + amount
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end
    debt
  end

  def self.T_pay_debt(loaner, debtor, amount)
    debt = Debt.find_by_loaner_id_and_debtor_id! loaner, debtor
    debt.lock!
    debt.update_attribute :amount, debt.amount - amount
    debt
  end

  def settle!(amount)
    ActiveRecord::Base.transaction do
      self.lock!
      self.update_attributes! amount: self.amount - amount
    end
  end

  def as_json(options={})
    super only: [:loaner_id, :debtor_id, :amount]
  end
end
