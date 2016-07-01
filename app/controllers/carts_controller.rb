class CartsController < ApplicationController
  def show
    @cart = current_dish_cart
  end

  def combo_summary
    @cart = current_combo_cart
  end
end
