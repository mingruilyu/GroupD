class Catering < ActiveRecord::Base
  belongs_to :shipping
  belongs_to :combo
  belongs_to :restaurant
  belongs_to :building

  validate :order_deadline_should_be_valid, 
    :arrival_time_should_be_valid, :combo_sould_belongs_to_restaurnt
  validates :estimated_arrival_at, :available_until, :combo_id, 
    :restaurant_id, :shipping_id, :building_id, presence: true

  scope :active, -> { joins(:shipping).merge(Shipping.not_done) }
  scope :by_restaurant, ->(restaurant) { 
    where restaurant_id: restaurant }
  scope :by_building, ->(building) { where building_id: building }
  scope :active_by_restaurant, ->(restaurant) {
    self.active.merge self.by_restaurant(restaurant) }
  scope :active_by_building, ->(building) {
    self.active.merge self.by_building(building) }
  # There could be moment the merchant switched the catering status
  # while customers are still ordering. To avoid race condition, we
  # simply forbid user's order SHUTTING_TIME_BEFORE_ORDER_DEADLINE
  # in advance of the catering's real deadline.
  SHUTTING_TIME_BEFORE_ORDER_DEADLINE = 30 # in second
  MIN_ORDER_TIME = 60 # in min 
  MIN_SHIPPING_TIME = 10 # in min

  def can_order?
    SHUTTING_TIME_BEFORE_ORDER_DEADLINE.second.from_now < \
      self.available_until
  end

  def update_time(delivery_date, deadline, delivery_time)
    Catering.transaction do
      self.lock!
      self.set_delivery_time delivery_date, delivery_time
      self.set_deadline delivery_date, deadline
      self.save!
    end
  end

  def self.create_caterings(combo, buildings, restaurant,
    delivery_date, deadline, delivery_time)
    Catering.transaction do
      buildings.each do |building|
        shipping = Shipping.create
        catering = Catering.new combo_id: combo.id, 
          restaurant_id: restaurant.id, building_id: building.id,
          shipping_id: shipping.id
        catering.set_delivery_time delivery_date, delivery_time
        catering.set_deadline delivery_date, deadline
        catering.save! 
      end
    end
  end

  def self.cancel_catering(catering, merchant_id)
    Catering.transaction do
      catering.lock!
      catering.shipping.destroy!
      price = catering.combo.price
      # generate refund transaction for all order items that have
      # been checked out
      order_items = OrderItem.checked_by_catering(catering.id)
      order_items.each do |item|
        customer_id = item.order.customer_id
        refund = price * item.quantity
        Transaction.create sender_id: merchant_id, 
          receiver_id: customer_id, amount: refund,
          purpose: Transaction::TYPE_REFUND
        Debt.T_pay_debt(merchant_id, customer_id, refund)
      end
      catering.destroy!
    end
  end

  def self.T_increase_order_count update_dict
    unless update_dict.empty?
      update_dict.each do |id, quantity|
        catering = Catering.find id
        catering.lock!
        catering.increment! :order_count, quantity
      end
    end
  end

  def self.T_decrease_order_count update_dict
    unless update_dict.empty?
      update_dict.each do |id, quantity|
        catering = Catering.find id
        catering.lock!
        catering.decrement! :order_count, quantity
      end
    end
  end

  def as_json(options={})
    json = super only: [:shipping_id, :combo_id, :building_id,
      :order_count]
    json['estimated_attrival_at'] = \
      self.estimated_arrival_at.to_s(:db) 
    json['available_until'] = self.available_until.to_s(:db)
    json
  end

  def set_deadline(date_int, time_int)
    self.available_until = Time.now.change(
      month: date_int / 100, day: date_int % 100, 
      hour: time_int / 100, min: time_int % 100)
  end

  def set_delivery_time(date_int, time_int)
    self.estimated_arrival_at = Time.now.change(
      month: date_int / 100, day: date_int % 100, 
      hour: time_int / 100, min: time_int % 100)
  end

  private

    def order_deadline_should_be_valid
      raise Exceptions::InvalidSetting \
        if Time.now > self.available_until
      raise Exceptions::InvalidSetting \
        if MIN_ORDER_TIME.minute.from_now > self.available_until  
    end

    def arrival_time_should_be_valid
      raise Exceptions::InvalidSetting \
        if self.available_until > self.estimated_arrival_at
      raise Exceptions::InvalidSetting \
        if self.available_until + MIN_SHIPPING_TIME.minute > \
          self.estimated_arrival_at 
    end

    def combo_sould_belongs_to_restaurnt
      raise Exceptions::NotAuthorized \
        if self.restaurant_id != self.combo.restaurant_id
    end
end
