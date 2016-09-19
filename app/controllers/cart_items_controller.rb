class CartItemsController < ApplicationController
  before_action :sanitize_cart_id
  before_action :sanitize_catering_id, only: [:new, :create]
  before_action :sanitize_cart_item_id, only: :destroy

  def new

    @cart_item = CartItem.new

    if current_cart.restaurant_id != @catering.restaurant_id 
      # check whether combo to order is from the same restaurant.
      # if not, we will have to clear all items in the cart.
      @clear_all_confirmation = true
    end

    respond_to do |format|
      format.js { render 'new' }
    end
  end

  def create
    
    if current_cart.restaurant_id != @catering.restaurant_id  
      unless current_cart.restaurant_id.nil?
        current_cart.clear_all
      end
      current_cart.update_attributes(
        restaurant_id:  @catering.restaurant_id)
    end

    cart_item = CartItem.new(
      quantity:             cart_item_params[:quantity].to_i,
      cart_id:              current_cart.id,
      catering_id:          @catering.id,
      special_instruction:  cart_item_params[:special_instruction]
    )

    if cart_item.save
      flash.now[:notice] = I18n.t('cart.notice.COMBO_ADDED')
    else
      flash.now[:error] = I18n.t('cart.error.COMBO_ADD_FAIL')
      respond_to do |format|
        format.js { render nothing: true, status: :bad_request }
      end and return
    end

    respond_to do |format|
      format.js { render 'create' }
    end
  end

  
  def destroy

    @cart_item.expected_cart_id = current_cart.id
    if @cart_item.destroy
      flash.now[:notice] = I18n.t('cart.notice.COMBO_DELETED')
    else
      flash.now[:error] = I18n.t('cart.error.COMBO_DELETE_FAIL')
      respond_to do |format|
        format.js { render nothing: true, status: :bad_request }
      end and return
    end

    respond_to do |format|
      format.js { render 'destroy' }
    end
  end

  private

    def cart_item_params
      params.require(:cart_item).permit(:quantity, 
        :catering_id, :special_instruction)
    end

    def sanitize_cart_id
      # we only allow users to operate on the current cart.
      render nothing: true, status: :bad_request \
        if params[:cart_id].to_i != current_cart.id
    end

    def sanitize_catering_id
      begin
        @catering = Catering.find(params[:catering_id] || 
          cart_item_params[:catering_id])
      rescue ActiveRecord::RecordNotFound
        render nothing: true, status: :bad_request
      end
    end

    def sanitize_cart_item_id
      begin
        @cart_item = CartItem.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render nothing: true, status: :bad_request
      end
    end
end
