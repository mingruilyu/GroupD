class CartItemsController < ApplicationController
  def new

    @cart_item = CartItem.new
    begin
      @catering = Catering.find(params[:catering_id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.js { render nothing: true, status: :not_found }
      end
    end
    puts 'CURRENT_CART ' + current_cart.to_s
    if current_cart.restaurant_id != @catering.combo.restaurant_id 
      # check whether combo to order is from the same restaurant.
      # if not, we will have to clear all items in the cart.
      @clear_all_confirmation = true
    end
    respond_to do |format|
      format.js { render 'cart_items/new' }
    end
  end

  def create

    catering = Catering.find(cart_item_params[:catering_id])
    cart = current_cart

    if cart.restaurant_id != catering.combo.restaurant_id  
      unless cart.restaurant_id.nil?
        cart.clear_all
      end
      cart.update_attributes(
        restaurant_id:  catering.combo.restaurant_id)
    end

    cart_item = CartItem.create(
      quantity:             cart_item_params[:quantity],
      cart_id:              cart.id,
      catering_id:          catering.id,
      special_instruction:  cart_item_params[:special_instruction]
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

  # Never trust parameters from the scary internet, only allow the
  # white list through.
  def cart_item_params
    @params ||= params.require(:cart_item).permit(:quantity, :cart_id,
      :catering_id, :special_instruction)
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
