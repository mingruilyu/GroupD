class ComboCartItemsController < ApplicationController
  def new

    @cart_item = CartItem.new
    @catering = Catering.find(params[:catering_id])
    if current_cart.restaurant_id != @catering.combo.restaurant_id 
      # check whether combo to order is from the same restaurant.
      # if not, we will have to clear all items in the cart.
      @clear_all_confirmation = true
    elsif current_cart.shipping_id.present? && 
      current_cart.shipping_id != @catering.shipping_id
      # check whether combo shares the same shipping with ones that
      # are already in the cart. if not, we will have to clear all
      # combo items in the cart. dish items are retained because 
      # shipping for dises are binding at the checkout.
      @clear_combo_confirmation = true
    end
    respond_to do |format|
      format.js { render 'cart_items/new' }
    end
  end

  def create

    catering = Catering.find(params[:cart_item][:catering_id])
    cart = current_cart

    if cart.restaurant_id != catering.combo.restaurant_id  
      unless cart.restaurant_id.nil?
        cart.clear_all
      end
      cart.update_attributes(
        restaurant_id:  catering.combo.restaurant_id, 
        shipping_id:    catering.shipping_id)
    elsif cart.shipping_id != catering.shipping_id
      unless cart.shipping_id.nil?
        cart.clear_combo
      end
      cart.update_attributes(shipping_id: catering.shipping_id)
    end

    cart_item = CartItem.create(
      quantity:             params[:cart_item][:quantity],
      cart_id:              cart.id,
      catering_id:          catering.id,
      special_instruction:  params[:cart_item][:special_instruction]
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
    @cart = current_cart

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
