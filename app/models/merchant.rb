class Merchant < Account
  has_many :restaurants
  has_many :debts, foreign_key: 'debtor_id'
  has_many :deposits, foreign_key: 'loaner_id'
end
