class Combo < ActiveRecord::Base 
  belongs_to :restaurant
  has_many :caterings
  serialize :dishes

  STATUS_ACTIVE =     0
  STATUS_END =        1
  STATUS_FULFILLED =  2
  STATUS_CANCEL =     3

  # Minimum time window open for customers to order
  MIN_ORDER_TIME = 60 # in min 
  # Minimum time required to prepare combo after order shutdown
  MIN_PREPARE_TIME = 30 # in min

  validates :price, numericality: { greater_than_or_equal_to: 0.01 }
  validate :should_have_enough_time_to_order

  scope :by_restaurant, ->(restaurant) { 
    where(restaurant_id: restaurant) }
  scope :active_by_restaurant, ->(restaurant) {
    where(status: STATUS_ACTIVE).merge(self.by_restaurant(
      restaurant)) }

  def self.create!(dishes, restaurant, price, url, time)
    Combo.transaction do
      restaurant.lock! 'LOCK IN SHARE MODE'
      combo = Combo.new restaurant_id: restaurant.id, price: price,
        image_url: url, available_until: time
      combo.dishes = []
      dishes.sort.each do |dish|
        dish.lock! 'LOCK IN SHARE MODE'
        combo.dishes.append dish.id
      end
      combo.save!
    end
  end

  def update!(dishes, price, url, time)
    ActiveRecord::Base.transaction do
      self.lock!
      self.dishes = []
      dishes.sort.each do |dish|
        dish.lock!('LOCK IN SHARE MODE')
        self.dishes.append dish.id
      end
      self.price = price
      self.image_url = url
      self.available_until = time
      self.save!
    end
  end

  def cancel!
    ActiveRecord::Base.transaction do
      self.lock!
      if self.L_cancelled?
        self.errors.add :base, 
          message: I18n.t('error.ALREADY_CANCELLED')
        raise Exceptions::NotEffective.new(self)
      end
      self.caterings.destroy_all
      # Casticadedly cancel all checkout or pending orders
      orders = ComboOrder.by_combo self.id
      orders.each do |order|
        order.cancel!
      end
      self.update_attribute :status, STATUS_CANCEL
    end
  end

  def as_json(options={})
    hash = super only: [:restaurant_id, :dishes]
    hash['price'] = self.price.as_json
    hash
  end

  def describe
    describe = []
    self.dishes.each do |id|
      dish = Dish.find id
      describe.append dish.name
    end
    describe.join ','
  end

  def available_until=(time)
    unless time.is_a? Time
      time = Helpers.timeint_to_time time
    end
    super time
  end

  def L_increment_order_count(quantity)
    self.increment! :order_count, quantity
  end

  def L_decrement_order_count(quantity)
    self.decrement! :order_count, quantity
  end

  def L_orderable?
    self.status == STATUS_ACTIVE
  end

  def L_requestable?
    self.status == STATUS_END
  end

  def L_cancelled?
    self.status == STATUS_CANCEL
  end

  private
    
    def should_have_enough_time_to_order
      MIN_ORDER_TIME.minute.from_now < self.available_until
    end
end
