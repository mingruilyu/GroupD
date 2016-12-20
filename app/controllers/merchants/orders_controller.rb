class Merchants::OrdersController < Merchants::MerchantController

  def approve
    @order.approve!
    render nothing: true
  end

  def pickup
    @order.pickup!
    render 
  end

  private
    
    def params_sanitization
      sanitize [:pickup, :pickup_settle, :approve], 
        merchant_id: :merchant, id: :order
    end

    def authorization
      authorize [:pickup, :pickup_settle, :approve] do
        [
          @merchant.id == @current_account.id,
          @order.restaurant.merchant_id == @current_account.id
        ]
      end
    end
end
