class Cart < ActiveRecord::Base
  has_many :cart_items, dependent: :destroy

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
end
