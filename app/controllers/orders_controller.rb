class OrdersController < ApplicationController

  before_filter :check_signed_in

  def new

    @cart = current_cart
    @order = Order.new(cart_id: @cart.id)
    @shipping = @cart.shipping
    if @shipping.present?
      @payments = current_account.payments.to_a.push(
        Payment.record_cash)
      @order.shipping_id = @shipping.id
      @order.set_taxes(@cart.total_price)
      @order.total_price = @cart.total_price + @shipping.price + 
        @order.taxes
    end
  end

  def create
    # check if the cart_items is still valid. For now, we only do
    # the check when users submit order for the cart. 
    # Todo we may later add some filter to the right controller.
    cart = Cart.find(order_params[:cart_id])
    shipping = cart.shipping
    if shipping.nil?
      flash[:error] = I18n.t("order.error.NO_SHIPPING")
    elsif not shipping.active?
      cart.invalidate_shipping
      flash[:error] = I18n.t('order.error.SHIPPING_OBSOLETE') 
    else
      # Todo this part should be transactional.
      # Todo make this part locked to ensure that no one else is 
      # changing the count values.
      cart.shipping.update_attribute(:customer_count, 
        cart.shipping.customer_count + 1)
      order = Order.create(order_params)

      catering_count_update = {}
      dish_count_update = {}
      cart.dish_items.each do |item|
        dish_count_update[item.dish.id] = { 
          'count': item.dish.count + item.quantity }
        # update cache
        item.dish.count += item.quantity
      end
      cart.combo_items.each do |item|
        catering_count_update[item.catering.id] = { 
          'count': item.catering.count + item.quantity }
        item.catering.count += item.quantity
      end
      unless catering_count_update.empty?
        Catering.update(catering_count_update.keys, 
          catering_count_update.values)
      end
      unless dish_count_update.empty?
        Dish.update(dish_count_update.keys, 
          dish_count_update.values)
      end

      if order.payment_id == Payment::RECORD_CASH_ID
        Debt.create(debtor_id: current_account.id,
          loaner_id: cart.restaurant.account_id)
      else
        # Todo embed other online payment platform APIs
        # initiate transaction
        Transaction.create(sender_id: current_account.id, 
          receiver_id: cart.restaurant.account_id,
          amount: order_params[:total_price])#
      end

      cart.update_attribute(:status, Cart::STATUS_CHECKOUT)
      session.delete(:cart)
      flash[:notice] = I18n.t("order.notice.ORDER_CREATED")
    end
    
    redirect_to root_path
  end
     
private

  def order_params
    oparams = params.require(:order).permit(:payment_id, 
      :shipping_id, :cart_id, :total_price)
    oparams[:total_price] = oparams[:total_price].to_f
    oparams
  end
end
