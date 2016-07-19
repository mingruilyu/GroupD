class CartsController < ApplicationController
  def show
    @dish_cart = current_dish_cart
    @combo_cart = current_combo_cart
  end

  def combo_summary
    @cart = current_combo_cart
    @total_price = 0

    if @cart.cart_items.present?
      @payments = current_account.payments.to_a.push(Payment.record_cash)
      @order = Order.new(cart_id: @cart.id, 
        shipping_id: @cart.shipping.id)
    end
  end
end
