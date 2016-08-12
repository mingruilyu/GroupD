require 'rails_helper'

RSpec.describe Order, type: :model do
  it 'list all orders of the specified customer' do
    customer = create(:customer)
    carts = create_list(:cart, 5, customer_id: customer.id)
    carts.each do |cart|
      Order.create(cart_id: cart.id, shipping_id: cart.shipping_id)
    end
    expect(Order.by_customer(customer.id).length).to eq 5
  end
end
