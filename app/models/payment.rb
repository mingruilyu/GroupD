class Payment < ActiveRecord::Base
  belongs_to :customer

  #validates :method, presence: true, uniqueness: { scope: :customer }
end
