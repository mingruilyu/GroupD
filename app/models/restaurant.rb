class Restaurant < ActiveRecord::Base
  belongs_to :merchant
  belongs_to :category
  has_many   :dishes
  belongs_to :location

  def closed_now?
    time = Time.now
    return time.hour > close_at / 100 || time.hour < open_at / 100 || (time.min > close_at % 100 || time.min < open_at % 100)
  end
  
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
