class Merchant::ShippingsController < Merchant::MerchantController
  def update
    @shipping.update_status!
    render nothing: true
  end

  private
    
    def params_sanitization
      sanitize :update, merchant_id: :merchant, id: :shipping
    end

    def authorization
      authorize :update do
        @merchant.id == @shipping.merchant_id 
      end
    end
end
