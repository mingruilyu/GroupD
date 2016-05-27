class OrdersController < ApplicationController
  def new
    @dropoff = Dropoff.find_by_company_id_and_restaurant_id(
      current_user.company_id, current_cart.id)

    @order = Order.new(cart_id: current_cart.id)
  end

  def create
  end
end
