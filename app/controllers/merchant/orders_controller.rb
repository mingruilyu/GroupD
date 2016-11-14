class Merchant::OrdersController < Merchant::MerchantController

  def update
    @order.pickup!
    render nothing: true
  end

  private
    
    def params_sanitization
      sanitize :update, id: :order
    end

    def authorization
      authorize :update do
        @order.restaurant.merchant_id == @current_account.id
      end
    end
end
