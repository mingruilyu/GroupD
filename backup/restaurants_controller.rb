class RestaurantsController < ApplicationController
  def index
    @merchants = Merchants.all
  end
end
