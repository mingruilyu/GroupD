class Restaurant < ActiveRecord::Base

  belongs_to :merchant
  belongs_to :category
  belongs_to :location
  belongs_to :city
  has_many   :dishes
  has_many   :combos
  has_many   :dropoffs

  validates :name, presence: true, uniqueness: true
  validates :certificate_url, presence: true
  validates :image_url, presence: true

  validate :open_close_time_should_be_valid

  validates_associated :category, :city, :merchant

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
  
  private

    def open_close_time_should_be_valid
      if self.open_at > self.close_at
        errors.add(:base, 
          I18n.t('restaurant.error.OPEN_LATER_THAN_CLOSE'))
      end
    end

    def category_should_be_valid 
      unless Category.find(self.category_id)
        errors.add(:base, I18n.t('category.error.INVALID_CATEGORY'))
      end
    end
end
