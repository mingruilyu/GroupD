class Cart < ActiveRecord::Base
  has_many :cart_items, dependent: :destroy

  UNCHECKOUTED = 0
  
  def total_items
    cart_items.length
  end
end
