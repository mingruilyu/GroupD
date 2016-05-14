class Restaurant < ActiveRecord::Base
  belongs_to :merchant
  
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
