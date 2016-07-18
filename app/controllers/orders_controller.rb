class OrdersController < ApplicationController

  before_filter :check_signed_in

  def new
    @dropoff = Dropoff.find_by_building_id_and_restaurant_id(
                current_or_guest_account.building_id, 
                current_dish_cart.restaurant_id)
    if @dropoff.present?
      @shippings = Shipping.where(dropoff_id: @dropoff.id, 
                    status: Shipping::SHIPPING_WAITING).where(
                      "estimated_arrival_at > now()") 
    end
    @order = Order.new(cart_id: current_dish_cart.id)
    @payments = current_account.payments.to_a.push(
      Payment.record_payment)
  end

  def create
    # check if the cart_items is still valid. For now, we only do
    # the check when users submit order for the cart. 
    # Todo we may later add some filter to the right controller.
    cart = Cart.find(order_params[:cart_id])
    
    # Todo this part should be transactional.
    # Todo make this part locked to ensure that no one else is 
    # changing the count values.
    if cart.is_combo_cart?
      cart.shipping.update_attribute(:customer_count, 
        cart.shipping.customer_count + 1)
    else
      shipping = Shipping.find(order_params[:shipping_id])
      shipping.update_attribute(:customer_count, 
        shipping.customer_count + 1) 
    end
    
    if cart.is_combo_cart? && !cart.shipping.active?
      flash.now[:error] = I18n.t('order.error.COMBO_OBSOLETE') 
      cart.clear
      @combo_obsolete = true
    else
      order = Order.create(order_params)
      count_update = {}
      cart.cart_items.each do |item|
        if item.is_dish?
          count_update[item.dish.id] = { 
            'count': item.dish.count + item.quantity }
          # update cache
          item.dish.count += item.quantity
        elsif item.is_combo?
          count_update[item.catering.id] = { 
            'count': item.catering.count + item.quantity }
          item.catering.count += item.quantity
        end
      end
      if cart.is_combo_cart?
        Catering.update(count_update.keys, count_update.values)
      else
        Dish.update(count_update.keys, count_update.values)
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
    end
    respond_to do |format|
      format.html {}
      format.js {}
    end
  end
     
private

  def order_params
    oparams = params.require(:order).permit(:payment_id, 
      :shipping_id, :cart_id, :total_price)
    oparams[:total_price] = oparams[:total_price].to_f
    oparams
  end
end
