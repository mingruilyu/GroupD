class Combo < ActiveRecord::Base 
  has_many :caterings, dependent: :delete_all
  belongs_to :restaurant

  MAX_DISH_COUNT = 5
  STATUS_AVAILABLE = 0
  STATUS_CANCELLED = 1

  validates :price, numericality: { greater_than_or_equal_to: 0.01 }

  scope :by_restaurant, ->(restaurant) { 
    where(restaurant_id: restaurant) }

  def self.create_combo(dishes, restaurant, price, url)
    Combo.transaction do
      restaurant.lock! 'LOCK IN SHARE MODE'
      combo = Combo.new restaurant_id: restaurant.id, price: price, image_url: url
      count = 1
      dishes.each do |dish|
        dish.lock! 'LOCK IN SHARE MODE'
        combo.associate_dish "dish_#{count}".to_sym, dish.id
        count += 1
      end
      combo.save!
    end
  end

  def update(dishes, price, url)
    raise Exceptions::NotEffective if self.cancelled?
    Combo.transaction do
      if price != self.price
        self.lock!
      end
      count = 1
      dishes.each do |dish|
        dish.lock!('LOCK IN SHARE MODE')
        write_attribute "dish_#{count}".to_sym, dish.id
        count += 1
      end
      while count < 6
        write_attribute "dish_#{count}".to_sym, nil
        count += 1 
      end
      self.price = price
      self.image_url = url
      self.save!
    end
  end

  def cancel
    raise Exceptions::NotEffective if self.cancelled?
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
    hash = super only: [:restaurant_id, :dish_1, :dish_2, :dish_3, 
      :dish_4, :dish_5]
    hash['price'] = self.price.as_json
    hash
  end

  def associate_dish attr_name, dish_id
    write_attribute attr_name, dish_id
  end

  protected

    def cancelled?
      self.status == STATUS_CANCELLED
    end
end
