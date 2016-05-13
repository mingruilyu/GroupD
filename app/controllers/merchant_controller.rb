class MerchantsController < ApplicationController
  # GET /merchants/:id
  def show
    @restaurant = current_merchant.restaurant
  end
end
