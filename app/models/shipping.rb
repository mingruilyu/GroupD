class Shipping < ActiveRecord::Base
  belongs_to :location
  belongs_to :restaurant
  belongs_to :building
  has_many :caterings

  STATUS_WAITING    = 0
  STATUS_DEPART     = 1
  STATUS_ARRIVE     = 2
  STATUS_PICKING_UP = 3
  STATUS_FULFILLED  = 4
  STATUS_CANCELLED  = 5

  MIN_SHIPPING_TIME = 10 # in min

  validate :delivery_time_should_be_valid
  validates :estimated_arrival_at, :location_id, :restaurant_id, 
    :building_id, presence: true

  scope :active, -> { where(status: STATUS_WAITING) }
  scope :by_restaurant, ->(restaurant) { 
    where restaurant_id: restaurant }
  scope :by_building, ->(building) { where building_id: building }
  scope :active_by_restaurant, ->(restaurant) {
    self.order(:created_at).active.merge(
      self.by_restaurant(restaurant)) }
  scope :active_by_building, ->(building) {
    self.order(:created_at).active.merge self.by_building(building) }

  def self.batch_create!(buildings, restaurant, deliver_time)
    location = restaurant.location.dup
    shippings = []
    ActiveRecord::Base.transaction do
      # Make sure no one is modifying restaurant while the shippings
      # are being created.
      restaurant.lock! 'LOCK IN SHARE MODE'
      buildings.each do |building|
        location.save!
        shipping = Shipping.create! location_id: location.id,
          estimated_arrival_at: deliver_time,
          restaurant_id: restaurant.id, building_id: building.id
        shippings.append shipping
      end
    end
    shippings
  end

  def T_fulfill!
    self.lock!
    self.update_attribute :status, STATUS_FULFILLED
  end

  def update_state!
    ActiveRecord::Base.transaction do
      self.lock!
      case self.status
      when STATUS_WAITING
        self.update_attribute :status, STATUS_DEPART
      when STATUS_DEPART
        self.update_attribute :status, STATUS_ARRIVE
      when STATUS_ARRIVE
        self.update_attribute :status, STATUS_PICKING_UP
      when STATUS_PICKING_UP
        self.update_attribute :status, STATUS_FULFILLED
      else
        self.errors.add :base, 
          message: I18n.t('error.UPDATE_WRONG_SHIPPING_STATUS')
        raise Exceptions::NotEffective.new(self)
      end
    end
  end

  def edit!(deliver_time)
    ActiveRecord::Base.transaction do
      self.lock!
      unless self.L_editable?
        self.errors.add :base, 
          message: I18n.t('error.CANCEL_CANNOT_BE_UPDATED')
        raise Exceptions::NotEffective.new(self)
      end
      self.update_attributes! estimated_arrival_at: deliver_time
    end
  end

  def cancel!
    ActiveRecord::Base.transaction do
      self.lock!
      unless self.L_cancellable?
        self.errors.add :base, 
          message: I18n.t('error.CANCEL_FINISHED_SHIPPING')
        raise Exceptions::NotEffective.new(self)
      end
      # Casticadedly cancel all checkout or pending orders
      orders = Order.by_shipping self.id
      orders.each do |order|
        order.cancel!
      end
      # Casticadedly cancel all caterings
      self.caterings.destroy_all
      self.update_attribute :status, STATUS_CANCELLED 
    end
  end

  def estimated_arrival_at=(time)
    unless time.is_a? Time
      # MMddHHmm: 12031230 means Dec, 3rd, 12:30
      time = Helpers.timeint_to_time time
    end
    super time
  end

  def as_json(options={})
    json = super only: [:restaurant_id, :building_id, :location_id]
    json['estimated_arrival_at'] = self.estimated_arrival_at.to_s(:db) 
    json
  end

  def as_wechat_msg(options={})
    WechatMessage::News.new title: self.restaurant.name, 
      description: self.combo.describe,
      pic_url: self.combo.image_url
  end

  def L_expired?
    self.status != STATUS_WAITING
  end

  protected

    def L_cancellable?
      self.status == STATUS_WAITING
    end

    def L_editable?
      self.status == STATUS_WAITING || self.status == STATUS_DEPART
    end

  private

    def delivery_time_should_be_valid
      self.errors[:estimated_arrival_at] = \
        I18n.t 'error.ORDER_DELIVERY_TIME_INVALID' \
        if (MIN_SHIPPING_TIME.minute.from_now > 
            self.estimated_arrival_at)
    end
end
