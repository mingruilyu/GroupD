class Food < ActiveRecord::Base

  STATUS_AVAILABLE    = 0
  STATUS_CANCELED     = 1

  belongs_to :restaurant

  validates :price, numericality: { greater_than_or_equal_to: 0.01 }
  validates :desc, text: true 
  validates :name, presence: true, name: true, uniqueness: { scope: :restaurant }
  validates :image_url, presence: true, url: true

  scope :by_restaurant, ->(restaurant) { 
    where(restaurant_id: restaurant) }
  scope :active_by_restaurant, ->(restaurant, delivery_time) {
    where(status: STATUS_AVAILABLE, restaurant_id: restaurant).where(
      'min_prepare_time < ?', (delivery_time - Time.now + 1) / 3600)\
    .where('quota > ?', 0) }

  def self.add!(attrs={})
    ActiveRecord::Base.transaction do
      # Here we relax the restaurant object, this means that we 
      # allows the situation where the restaurant is deleted before a
      # dish added to it.
      # restaurant.lock! 'LOCK IN SHARE MODE'
      Food.create! attrs
    end
  end

  def update!(attrs={})
    self.update_attributes! attrs
  end

  def cancel!
    ActiveRecord::Base.transaction do
      self.lock!
      if self.L_canceled?
        self.errors.add :base, 
          message: I18n.t('error.ALREADY_CANCELLED')
        raise Exceptions::NotEffective.new(self)
      end
      # Casticadedly cancel all checkout or pending orders
      orders = Order.by_food self.id
      orders.each do |order|
        order.cancel!
      end
      self.update_attribute :status, STATUS_CANCELED
    end  
  end

  def as_wechat_news
    # TODO set url to actual url
    WechatMessage::News.new title: self.name,
      description: self.desc, pic_url: self.image_url,
      url: self.image_url
  end

  def as_json(options={})
    hash = super only: [:restaurant_id, :desc, :image_url, :name]
    hash['price'] = self.price.as_json
    hash
  end

  def L_increment_order_count(quantity)
    self.increment! :order_count, quantity
  end

  def L_decrement_order_count(quantity)
    self.decrement! :order_count, quantity
  end

  def L_canceled?
    self.status == STATUS_CANCELED
  end

  def L_requestable?
    self.status == STATUS_AVAILABLE
  end

  def L_orderable?(shipping, quantity)
    self.status == STATUS_AVAILABLE && self.quota > quantity && \
      self.min_prepare_time.hour.from_now < \
      shipping.estimated_arrival_at
  end

end
