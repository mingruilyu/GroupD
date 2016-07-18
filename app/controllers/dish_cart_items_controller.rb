class DishCartItemsController < ApplicationController
  def new
    @cart_item = CartItem.new
    @dish = Dish.find(params[:dish_id]) 
    # check whether dish to order is from the same restaurant out of
    # which the cart in session by adding first dish to the it.
    if current_dish_cart.restaurant_id != @dish.restaurant_id
      @confirmation_required = true
    end
    respond_to :js
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

    # Todo check if shipping_id is different for combo_cart.

    @cart_item = CartItem.new(
      quantity:             params[:cart_item][:quantity],
      account_id:           current_or_guest_account.id,
      cart_id:              cart.id,
      special_instruction:  params[:cart_item][:special_instruction]
    )
    
    @cart_item.dish_id = @dish.id
    flash.now[:notice] = I18n.t('cart.notice.DISH_ADDED', 
                                name: @dish.name)
    @cart_item.save
    respond_to :js
  end

  def destroy
    cart_item = CartItem.find(params[:id])
    @cart = current_dish_cart
    cart_item.destroy
    respond_to :js
  end
end
