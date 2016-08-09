class Order < ActiveRecord::Base
  belongs_to :shipping
  belongs_to :cart

  validates_associated :cart, :shipping

  TAX_RATE = 0.1
  attr_accessor :total_price
  attr_accessor :payment_id
  attr_reader   :taxes

  scope :by_customer, ->(customer) { 
    joins(:cart).merge(Cart.where(account_id: customer).includes(:cart_items)) }

  def set_taxes(subtotal)
    @taxes = subtotal * TAX_RATE
  end
end
