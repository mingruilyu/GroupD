class Cart < ActiveRecord::Base
  has_many :cart_items, dependent: :delete_all
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
        @total_price += item.catering.combo.price * item.quantity
      end
    end
    @total_price 
  end

  def invalidate_shipping
    self.cart_items.clear
    self.shipping_id = nil
    self.save
  end

  def has_expired?
    self.cart_items.each do |item|
      return true unless item.catering.can_order?
    end
    return false
  end

  def T_checkout!
    self.lock! 'LOCK IN SHARE MODE'
    update_attribute :status, STATUS_CHECKOUT
  end
end
