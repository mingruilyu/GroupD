class CartItemsController < ApplicationController
  def new
    @cart_item = CartItem.new
    @dish = Dish.find(params[:dish_id])
    respond_to :js
  end

  def create
  end

  def show
  end
end
