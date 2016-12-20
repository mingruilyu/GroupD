class Merchant::ShippingsController < Merchant::MerchantController
  def create
    Shipping.batch_create! @buildings, @restaurant, @deliver_time
    render nothing: true, status: :created 
  end

  def update
    @shipping.edit! @deliver_time
    render nothing: true
  end

  def update_state
    @shipping.update_state!
    render nothing: true
  end

  def destroy
    @shipping.cancel!
    render nothing: true
  end

  def list_orders
    checked = Order.checkout_by_shipping @shipping.id
    delivered = Order.delivered_by_shipping @shipping.id
    render json: Response::JsonResponse.new(checked + delivered)
  end

  private
    
    def params_sanitization
      sanitize :create, merchant_id: :merchant, 
        restaurant_id: :restaurant, buildings: :buildings, 
        deliver_time: :time_int
      sanitize [:destroy, :update_state, :list_orders], 
        merchant_id: :merchant, id: :shipping 
      sanitize :update, merchant_id: :merchant, id: :shipping, 
        deliver_time: :time_int
    end
    
    def authorization
      authorize [:update, :destroy, :update_state, :list_orders] do 
        [
          @merchant.id == current_account.id,
          @shipping.restaurant.merchant_id == @merchant.id
        ]
      end
      authorize :create do
        [
          @merchant.id == current_account.id,
          @restaurant.merchant_id == @merchant.id
        ]
      end
    end
end
