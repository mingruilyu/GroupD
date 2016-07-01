class CartItemsController < ApplicationController
  def new
    @cart_item = CartItem.new
    @dish = Dish.find(params[:dish_id]) 

    if @dish.is_dish?
      # check whether dish to order is from the same restaurant out of which
      # the cart in session by adding first dish to the it.
      if  current_dish_cart.restaurant_id.present? \
        && current_dish_cart.restaurant_id != @dish.restaurant_id
          @confirmation_required = true
      end
    end
    respond_to :js
  end

  def create
    @dish = Dish.find(params[:cart_item][:dish_id])
    
    cart = @dish.is_dish ? current_dish_cart : current_combo_cart

    if cart.restaurant_id != @dish.restaurant_id
      cart.cart_items.each do |cart_item|
        cart_item.destroy
      end
      cart.restaurant_id = @dish.restaurant_id
    end

    cart.update_attribute(:restaurant_id, @dish.restaurant_id)
    
    @cart_item = CartItem.create(
      quantity:             params[:cart_item][:quantity],
      account_id:           current_or_guest_account.id,
      dish_id:              @dish.id,
      cart_id:              cart.id,
      special_instruction:  params[:cart_item][:special_instruction]
    )

    if @dish.is_dish?
      flash.now[:notice] = I18n.t('cart.notice.DISH_ADDED', 
                                  name: @dish.name)
    end
    respond_to :js
  end

  def destroy
    cart_item = CartItem.find(params[:id])
    if cart_item.dish.is_dish?
      @cart = current_dish_cart
    else
      @combo_item_destroy = true 
    end
    cart_item.destroy
    respond_to :js
  end

end
