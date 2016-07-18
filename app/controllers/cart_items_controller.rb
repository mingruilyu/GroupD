class CartItemsController < ApplicationController
  def new
    @cart_item = CartItem.new
    if params[:catering_id].nil?
      @dish = Dish.find(params[:dish_id]) 
      # check whether dish to order is from the same restaurant out of
      # which the cart in session by adding first dish to the it.
      if current_dish_cart.restaurant_id != @dish.restaurant_id
        @confirmation_required = true
      end
    else
      @catering = Catering.find(params[:catering_id])
      if current_combo_cart.restaurant_id != 
        @catering.combo.restaurant_id || 
        current_combo_cart.shipping_id != @catering.shipping_id
        @confirmation_required = true
      end
    end
    respond_to :js
  end

  def create
    if params[:cart_item][:dish_id].present?
      @dish = Dish.find(params[:cart_item][:dish_id])
      cart = current_dish_cart
      restaurant_id = @dish.restaurant_id
    else
      @catering = Catering.find(params[:cart_item][:catering_id])
      cart = current_combo_cart
      restaurant_id = @catering.combo.restaurant_id
    end

    if cart.restaurant_id != restaurant_id
        cart.cart_items.each do |cart_item|
          cart_item.destroy
        end
        if params[:cart_item][:dish_id].present?
          cart.update_attribute(:restaurant_id, restaurant_id)
        else
          cart.update_attributes(restaurant_id: restaurant_id, 
            shipping_id: @catering.shipping_id)
        end
    end

    # Todo check if shipping_id is different for combo_cart.

    @cart_item = CartItem.new(
      quantity:             params[:cart_item][:quantity],
      account_id:           current_or_guest_account.id,
      cart_id:              cart.id,
      special_instruction:  params[:cart_item][:special_instruction]
    )
    
    if params[:cart_item][:dish_id].present?
      @cart_item.dish_id = @dish.id
      flash.now[:notice] = I18n.t('cart.notice.DISH_ADDED', 
                                  name: @dish.name)
    else
      @cart_item.catering_id = @catering.id
      flash.now[:notice] = I18n.t('cart.notice.DISH_ADDED', 
                                  name: @catering.combo.name)
    end
    @cart_item.save
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
