class Cart < ActiveRecord::Base
  has_many :cart_items, dependent: :destroy
  belongs_to :restaurant
  belongs_to :shipping

  UNCHECKOUTED = 0
  
  def total_items
    cart_items.length
  end

  def total_price
    total = 0
    cart_items.each do |cart_item|
      total += cart_item.dish.price
    end
    total
  end

  def clear
    self.cart_items.clear
  end

  def is_combo_cart?
    self.shipping_id.present?
  end

  def is_dish_cart?
    self.shipping_id.nil?
  end
end
