class MerchantsController < ApplicationController
  # GET /merchants/:id
  def show
    @restaurant = current_merchant.restaurant
  #  @orders = @restaurant.orders
  #  @transactions = @restaurant.transactions
  #  @shippings = @restaurant.shippings
  end
end
