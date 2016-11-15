class Catering < ActiveRecord::Base
  belongs_to :shipping
  belongs_to :combo
  belongs_to :restaurant
  belongs_to :building

  STATUS_ACTIVE = 0
  STATUS_DONE = 1
  STATUS_CANCELLED = 2

  validate :order_deadline_should_be_valid, 
    :arrival_time_should_be_valid
  validates :estimated_arrival_at, :available_until, :combo_id, 
    :restaurant_id, :shipping_id, :building_id, presence: true

  scope :active, -> { where(status: STATUS_ACTIVE) }
  scope :by_restaurant, ->(restaurant) { 
    where restaurant_id: restaurant }
  scope :by_building, ->(building) { where building_id: building }
  scope :active_by_restaurant, ->(restaurant) {
    self.order(:created_at).active.merge(
      self.by_restaurant(restaurant)) }
  scope :active_by_building, ->(building) {
    self.order(:created_at).active.merge self.by_building(building) }
  scope :active_by_combo, ->(combo) {
    self.order(:created_at).active.merge where(combo_id: combo) }
  # There could be moment the merchant switched the catering status
  # while customers are still ordering. To avoid race condition, we
  # simply forbid user's order SHUTTING_TIME_BEFORE_ORDER_DEADLINE
  # in advance of the catering's real deadline.
  SHUTTING_TIME_BEFORE_ORDER_DEADLINE = 30 # in second
  MIN_ORDER_TIME = 60 # in min 
  MIN_SHIPPING_TIME = 10 # in min

  def can_order?
    !self.done? && \
      SHUTTING_TIME_BEFORE_ORDER_DEADLINE.second.from_now < \
        self.available_until
  end

  def done?
    self.status == STATUS_DONE
  end

  def T_fulfill!
    self.lock!
    self.update_attribute :status, STATUS_DONE
  end

  def self.get_recent_menu_by_building(building_id)
    self.active_by_building(building_id)
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
      restaurant.lock! 'LOCK IN SHARE MODE'
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

  def cancel
    if self.done?
      self.errors.add :base, 
        message: I18n.t('error.CANCEL_FINISHED_CATERING')
      raise Exceptions::NotEffective.new(self)
    end
    Catering.transaction do
      self.lock!
      self.shipping.destroy!
      self.status = STATUS_CANCELLED 
      self.shipping_id = 0
      self.save!
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

  def as_json(options={})
    json = super only: [:shipping_id, :combo_id, :building_id,
      :order_count]
    json['estimated_attrival_at'] = \
      self.estimated_arrival_at.to_s(:db) 
    json['available_until'] = self.available_until.to_s(:db)
    json
  end

  def as_wechat_msg(options={})
    WechatMessage::News.new title: self.restaurant.name, 
      description: self.combo.describe,
      pic_url: self.combo.image_url,
      url: self.combo.image_url
  end

  private

    def order_deadline_should_be_valid
      self.errors[:available_until] = \
        I18n.t 'error.ORDER_DEADLINE_INVALID' \
        if (Time.now > self.available_until ||
          MIN_ORDER_TIME.minute.from_now > self.available_until)
    end

    def arrival_time_should_be_valid
      self.errors[:estimated_arrival_at] = \
        I18n.t 'error.ARRIVAL_TIME_INVALID' \
        if (self.available_until > self.estimated_arrival_at ||
          (self.available_until + MIN_SHIPPING_TIME.minute > 
           self.estimated_arrival_at))
    end
end
