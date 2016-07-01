class OrdersController < ApplicationController
  def new
    @dropoff = Dropoff.find_by_building_id_and_restaurant_id(
                current_or_guest_account.building_id, 
                current_dish_cart.restaurant_id)
    if @dropoff.present?
      @shippings = Shipping.where(dropoff_id: @dropoff.id, 
                    status: Shipping::SHIPPING_WAITING).where(
                      "estimated_arrival_at > now()") 
    end
    @order = Order.new()
  end

  def create
  end
end
