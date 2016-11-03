class Combo < ActiveRecord::Base 
  has_many :caterings, dependent: :delete_all
  belongs_to :restaurant
  serialize :dishes

  MAX_DISH_COUNT = 5
  STATUS_AVAILABLE = 0
  STATUS_CANCELLED = 1

  validates :price, numericality: { greater_than_or_equal_to: 0.01 }

  scope :by_restaurant, ->(restaurant) { 
    where(restaurant_id: restaurant) }

  scope :recent_by_restaurant, ->(restaurant) {
    distinct.joins(:caterings).merge(
      Catering.active_by_restaurant(restaurant)) }

  def self.create_combo(dishes, restaurant, price, url)
    Combo.transaction do
      restaurant.lock! 'LOCK IN SHARE MODE'
      combo = Combo.new restaurant_id: restaurant.id, price: price,
        image_url: url
      combo.dishes = []
      dishes.sort.each do |dish|
        dish.lock! 'LOCK IN SHARE MODE'
        combo.dishes.append dish.id
      end
      combo.save!
    end
  end

  def update(dishes, price, url)
    if self.cancelled?
      self.errors.add :base, 
        message: I18n.t('error.UPDATE_CANCELLED_COMBO')
      raise Exceptions::NotEffective.new(self)
    end
    Combo.transaction do
      if price != self.price
        self.lock!
      end
      self.dishes = []
      dishes.sort.each do |dish|
        dish.lock!('LOCK IN SHARE MODE')
        self.dishes.append dish.id
      end
      self.price = price
      self.image_url = url
      self.save!
    end
  end

  def cancel
    if self.cancelled?
      self.errors.add :base, 
        message: I18n.t('error.CANCELLED_CANCELLED_COMBO')
      raise Exceptions::NotEffective.new(self)
    end
    caterings = Catering.active_by_combo self.id
    Combo.transaction do
      unless caterings.empty?
        self.update_attribute :status, STATUS_CANCELLED 
      else
        self.destroy!
      end
    end
    return caterings  
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

  protected

    def cancelled?
      self.status == STATUS_CANCELLED
    end
end
