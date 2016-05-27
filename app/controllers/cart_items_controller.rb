class CartItemsController < ApplicationController
  def new
    @cart_item = CartItem.new
    @dish = Dish.find(params[:dish_id])
    
    # check whether dish to order is from the same restaurant out of which
    # the cart in session by adding first dish to the it.
    if  current_cart.restaurant_id.present? \
      && current_cart.restaurant_id != @dish.restaurant_id
        @confirmation_required = true
    end

    respond_to :js
  end

  def create
    cart = current_cart
    dish = Dish.find(params[:cart_item][:dish_id])

    if cart.restaurant_id != dish.restaurant_id
      cart.cart_items.each do |cart_item|
        cart_item.destroy
      end
      cart.restaurant_id = dish.restaurant_id
    end

    cart.update_attribute(:restaurant_id, dish.restaurant_id)
    
    @cart_item = CartItem.create(
      quantity:             params[:cart_item][:quantity],
      user_id:              current_user.id,
      dish_id:              dish.id,
      cart_id:              cart.id,
      special_instruction:  params[:cart_item][:special_instruction]
    )

    flash.now[:notice] = I18n.t('cart.notice.DISH_ADDED', 
                               name: dish.name)
    respond_to :js
  end

  def destroy
    CartItem.destroy(params[:id])
    @cart = current_cart
    respond_to :js
  end

end
