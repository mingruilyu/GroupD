class Restaurant < ActiveRecord::Base
  belongs_to :merchant
  belongs_to :category
  belongs_to :location
  has_many   :dishes
  has_many   :combos
  has_many   :dropoffs

  def closed_now?
    time = Time.now
    time.hour > close_at / 100 || time.hour < open_at / 100 \
      || (time.min > close_at % 100 || time.min < open_at % 100)
  end

  def active_combos
    Combo.active_by_restaurant(self.id).distinct.includes(:shippings) 
  end

  def dishes
    Dish.where(restaurant_id: self.id, type: 'Dish')
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
