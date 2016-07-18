class Debt < ActiveRecord::Base
  belongs_to :customer, foreign_key: 'debtor_id'
  belongs_to :merchant, foreign_key: 'loaner_id'
end
