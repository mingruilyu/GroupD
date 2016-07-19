class DishCartItemsController < ApplicationController
  def new
    @cart_item = CartItem.new
    @dish = Dish.find(params[:dish_id]) 
    # check whether dish to order is from the same restaurant out of
    # which the cart in session by adding first dish to the it.
    if current_dish_cart.restaurant_id != @dish.restaurant_id
      @confirmation_required = true
    end
    respond_to do |format|
      format.js { render 'cart_items/new' }
    end
  end

  def create
    @dish = Dish.find(params[:cart_item][:dish_id])
    cart = current_dish_cart
    restaurant_id = @dish.restaurant_id

    if cart.restaurant_id != restaurant_id
      cart.cart_items.each do |cart_item|
        cart_item.destroy
      end
      cart.update_attribute(:restaurant_id, restaurant_id)
    end

    cart_item = CartItem.new(
      quantity:             params[:cart_item][:quantity],
      account_id:           current_or_guest_account.id,
      cart_id:              cart.id,
      dish_id:              @dish.id,
      special_instruction:  params[:cart_item][:special_instruction]
    )
    
    if cart_item.save
      flash.now[:notice] = I18n.t('cart.notice.DISH_ADDED', 
        name: @dish.name)
    else
      flash.now[:error] = I18n.t('cart.error.DISH_ADD_FAIL', 
        name: @dish.name)
    end

    respond_to do |format|
      format.js { render 'cart_items/create' }
    end
  end

  def destroy
    cart_item = CartItem.find(params[:id])
    @cart = current_dish_cart
    cart_item.destroy
    
    if cart_item.destroy
      flash.now[:notice] = I18n.t('cart.notice.DISH_DELETED', 
        name: cart_item.dish.name)
    else
      flash.now[:error] = I18n.t('cart.error.COMBO_DELETED',
        name: cart_item.dish.name)
    end

    respond_to do |format|
      format.js { render 'cart_items/destroy' }
    end
  end
end
