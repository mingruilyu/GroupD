class Catering < ActiveRecord::Base
  belongs_to :shipping
  belongs_to :combo
  belongs_to :restaurant
  belongs_to :building, -> { includes :company, :city }

  validate :order_deadline_should_be_valid
  validates :estimated_arrival_at, presence: true

  validates_associated :combo

  attr_accessor :building_list
  attr_accessor :delivery_time
  attr_accessor :delivery_date

  scope :active, -> { joins(:shipping).merge(Shipping.active) }
  scope :by_restaurant, ->(restaurant_id) \
    { joins(:shipping).merge(Shipping.by_restaurant(restaurant_id)) }
  scope :active_by_restaurant, ->(restaurant_id) \
    { joins(:shipping).merge(
        Shipping.by_restaurant(restaurant_id).active) }
  scope :active_by_building, ->(building_id) \
    { joins(:shipping).merge(
        Shipping.by_building(building_id).active) }

  SHUTTING_TIME_BEFORE_ORDER_DEADLINE = 30 # in second
  MIN_ORDER_TIME = 3600 # in second 
  MIN_SHIPPING_TIME = 3600 # in second


  def combo_name
    self.combo.name
  end

  def restaurant_name
    self.restaurant.name
  end

  def can_order?
    SHUTTING_TIME_BEFORE_ORDER_DEADLINE.second.from_now < \
      self.available_until
  end

  def set_deadline(date, time_int)
    self.available_until = DateTime.now.beginning_of_day.change(
      day: date, hour: time_int / 100, min: time_int % 100)
  end

  def set_delivery_time(date, time_int, asap)
    self.estimated_arrival_at = 
      DateTime.now.beginning_of_day.change(
        day: date, hour: time_int / 100, min: time_int % 100)
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

  private
    
    def order_deadline_should_be_valid
      # enough time for user to order
      # enough time for shipping
    end

    def arrival_time_should_be_valid
  if self.available_until + SHIPPING_DEADLINE_MIN_BUFFER_TIME > 
        self.estimated_arrival_at
        errors.add(:base,
          I18n.t('shipping.error.NOT_ENOUGH_PREPARE_TIME'))
      elsif self.available_until < Time.now
        errors.add(:base, 
          I18n.t('shipping.error.DEADLINE_IN_PAST'))
      end

    end

end
