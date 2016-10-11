class Dish < ActiveRecord::Base
  belongs_to  :restaurant

  STATUS_AVAILABLE = 0
  STATUS_SOLD_OUT = 1
  STATUS_REMOVED = 2

  validates :name, presence: true, uniqueness: { scope: :restaurant }
  validates :price, numericality: { greater_than_or_equal_to: 0.01 }
  validates :image_url, presence: true
  
  scope :active_by_restaurant, ->(restaurant) { 
    where(restaurant_id: restaurant).where('status != ?', 
      STATUS_REMOVED) }

  def update(image_url, price, desc)
    Dish.transaction do
      if price != self.price
        self.lock!
      end
      self.update_attributes image_url: image_url, price: price,
        desc: desc 
    end
  end

  def destroy
    # we don't just remove the dish from database. this will cause
    # the casticated destruction of the dish's dependent, e.g., combo,
    # catering, order, which we don't want. instead, those combos that
    # contain the dish are still valid. Destroying a dish won't have
    # any effect on the combos. 
    Dish.transaction do
      self.lock!
      self.update_attribute :status, STATUS_REMOVED
    end
  end

  def as_json(options={})
    hash = super only: [:restaurant_id, :desc, :image_url, :name]
    hash['price'] = self.price.as_json
    hash
  end

  def belongs_to?(merchant_id)
    return false if Restaurant.where(id: self.restaurant_id, 
      merchant_id: merchant_id).empty?
    true
  end
end
