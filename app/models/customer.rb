class Customer < Account
  belongs_to :building
  has_many :payments
  has_many :debts, foreign_key: 'debtor_id'
  has_many :deposit, foreign_key: 'loaner_id'
end
