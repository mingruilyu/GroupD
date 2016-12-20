class Dish < ActiveRecord::Base
  belongs_to  :restaurant

  STATUS_AVAILABLE = 0
  STATUS_SOLD_OUT = 1
  STATUS_CANCELED = 2

  validates :name, presence: true, uniqueness: { scope: :restaurant }, 
    name: true
  validates :price, numericality: { greater_than_or_equal_to: 0.01 }
  validates :image_url, presence: true, url: true
  validates :desc, text: true 
  
  scope :active_by_restaurant, ->(restaurant) { 
    where(restaurant_id: restaurant, status: STATUS_AVAILABLE) }

  def update!(image_url, price, name, desc)
    Dish.transaction do
      if price != self.price
        self.lock!
      end
      self.update_attributes! image_url: image_url, price: price, 
        name: name, desc: desc
    end
  end

  def cancel!
    # we don't just remove the dish from database. this will cause
    # the casticated destruction of the dish's dependent, e.g., combo,
    # catering, order, which we don't want. instead, those combos that
    # contain the dish are still valid. Destroying a dish won't have
    # any effect on the combos. 
    ActiveRecord::Base.transaction do
      self.lock!
      if self.L_canceled?
        self.errors.add :base, 
          message: I18n.t('error.ALREADY_CANCELLED')
        raise Exceptions::NotEffective.new(self)
      end
      self.update_attribute :status, STATUS_CANCELED
      # Casticadedly cancel all checkout or pending orders
      orders = DishOrder.by_dish self.id
      orders.each do |order|
        order.cancel!
      end
    end
  end

  def L_increment_order_count(quantity)
    self.increment! :order_count, quantity
  end

  def L_decrement_order_count(quantity)
    self.decrement! :order_count, quantity
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
  
  def L_orderable?(shipping)
    self.status == STATUS_AVAILABLE && \
      self.min_prepare_time.hour.from_now < \
        shipping.estimated_arrival_at
  end

  def L_canceled?
    self.status == STATUS_CANCELED
  end
end
