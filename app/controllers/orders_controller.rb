class OrdersController < ApplicationController
  def new
    @dropoff = Dropoff.find_by_building_id_and_restaurant_id(
      current_user.building_id, current_cart.restaurant_id)
    if @dropoff.present?
      @shippings = Shipping.where(dropoff_id: @dropoff.id, 
                    status: Shipping::SHIPPING_WAITING) 
    end
    @order = Order.new(cart_id: current_cart.id)
  end

  def create
  end
end
