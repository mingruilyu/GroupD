class Order < ActiveRecord::Base
  belongs_to :shipping
  belongs_to :cart
  belongs_to :payment

  TAX_RATE = 0.1
  attr_accessor :total_price
  attr_reader   :taxes

  def set_taxes(subtotal)
    @taxes = subtotal * TAX_RATE
  end
end
