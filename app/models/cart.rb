class Cart < ActiveRecord::Base
  has_many :cart_items
  belongs_to :restaurant
  belongs_to :shipping

  STATUS_UNCHECKOUT = false
  STATUS_CHECKOUT = true
  
  def total_items
    cart_items.length
  end

  def total_price
    if @total_price.nil?
      @total_price = 0
      self.cart_items.each do |item|
        if item.is_dish?
          @total_price += item.dish.price * item.quantity
        elsif item.is_combo?
          @total_price += item.catering.combo.price * item.quantity
        end
      end
    end
    @total_price 
  end

  def clear_all
    self.cart_items.clear
  end

  def clear_combo
    self.combo_items.clear
  end

  def clear_dish
    self.dish_items.clear
  end

  def combo_items
    CartItem.where(cart_id: self.id).where('catering_id IS NOT NULL').includes(:catering)
  end

  def dish_items
    CartItem.where(cart_id: self.id).where('dish_id IS NOT NULL').includes(:dish)
  end

  def invalidate_shipping
    self.combo_items.clear
    self.shipping_id = nil
    self.save
  end
end
