class ComboCartItemsController < ApplicationController
  def new

    @cart_item = CartItem.new
    @catering = Catering.find(params[:catering_id])
    # check whether dish to order is from the same restaurant out of
    # which the cart in session by adding first dish to the it.
    if current_combo_cart.restaurant_id != 
      @catering.combo.restaurant_id || 
      current_combo_cart.shipping_id != @catering.shipping_id
      @confirmation_required = true
    end
    respond_to do |format|
      format.js { render 'cart_items/new' }
    end
  end

  def create

    @catering = Catering.find(params[:cart_item][:catering_id])
    cart = current_combo_cart

    if cart.restaurant_id != @catering.combo.restaurant_id || 
      cart.shipping_id != @catering.shipping_id
        cart.cart_items.each do |cart_item|
          cart_item.destroy
        end
        cart.update_attributes(
          restaurant_id:  @catering.combo.restaurant_id, 
          shipping_id:    @catering.shipping_id)
    end

    cart_item = CartItem.create(
      quantity:             params[:cart_item][:quantity],
      account_id:           current_or_guest_account.id,
      cart_id:              cart.id,
      special_instruction:  params[:cart_item][:special_instruction],
      catering_id:          @catering.id
    )

    if cart_item.save
      flash.now[:notice] = I18n.t('cart.notice.COMBO_ADDED')
    else
      flash.now[:error] = I18n.t('cart.error.COMBO_ADD_FAIL')
    end

    respond_to do |format|
      format.js { render 'cart_items/create' }
    end
  end

  def destroy
    cart_item = CartItem.find(params[:id])
    @cart = current_combo_cart

    if cart_item.destroy
      flash.now[:notice] = I18n.t('cart.notice.COMBO_DELETED')
    else
      flash.now[:error] = I18n.t('cart.error.COMBO_DELETE_FAIL')
    end

    respond_to do |format|
      format.js { render 'cart_items/destroy' }
    end
  end
end
