class Order < ActiveRecord::Base
  belongs_to :cart
  belongs_to :customer

  validates_associated :cart

  TAX_RATE = 0.1
  attr_accessor :payment_id
  attr_reader   :taxes

  scope :by_customer, ->(customer) { 
    where(customer_id: customer).merge(Cart.includes(:cart_items, :restaurant)) }

  def set_taxes(subtotal)
    @taxes = subtotal * TAX_RATE
  end

end
