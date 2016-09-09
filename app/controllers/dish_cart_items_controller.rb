class CartItemsController < ApplicationController
  def new

    @cart_item = CartItem.new
    @dish = Dish.find(params[:dish_id]) 
    # check whether dish to order is from the same restaurant.
    # if not, we will have to clear all items in the cart.
    if current_cart.restaurant_id != @dish.restaurant_id
      @clear_all_confirmation = true
    end
    respond_to do |format|
      format.js { render 'cart_items/new' }
    end
  end

  def create

    dish = Dish.find(params[:cart_item][:dish_id])
    cart = current_cart

    if cart.restaurant_id != dish.restaurant_id
      unless cart.restaurant_id.nil?
        cart.clear_all
      end
      cart.update_attribute(:restaurant_id, dish.restaurant_id)
    end

    cart_item = CartItem.new(
      quantity:             params[:cart_item][:quantity],
      cart_id:              cart.id,
      dish_id:              dish.id,
      special_instruction:  params[:cart_item][:special_instruction]
    )
    
    if cart_item.save
      flash.now[:notice] = I18n.t('cart.notice.DISH_ADDED', 
        name: dish.name)
    else
      flash.now[:error] = I18n.t('cart.error.DISH_ADD_FAIL', 
        name: dish.name)
    end

    respond_to do |format|
      format.js { render 'cart_items/create' }
    end
  end

  def destroy
    cart_item = CartItem.find(params[:id])
    @cart = current_cart
    
    if cart_item.destroy
      flash.now[:notice] = I18n.t('cart.notice.DISH_DELETED', 
        name: cart_item.dish.name)
    else
      flash.now[:error] = I18n.t('cart.error.DISH_DELETE_FAIL',
        name: cart_item.dish.name)
    end

    respond_to do |format|
      format.js { render 'cart_items/destroy' }
    end
  end
end
