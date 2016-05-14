class Restaurant < ActiveRecord::Base
  belongs_to :merchant
  belongs_to :category
  has_many   :dishes
  
  def transactions
    @transactions
  end

  def revenue
    sum = 0

  end

  def loans
    # user's debts is merchant's loan
    self.debt
  end

end
