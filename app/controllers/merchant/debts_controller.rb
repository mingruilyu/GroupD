class Merchant::DebtsController < Merchant::MerchantController
  def index
    debts = Debt.by_loaner @merchant.id
    render json: Response::JsonResponse.new(debts)
  end
  
  private
    
    def params_sanitization
      sanitize :index, merchant_id: :merchant
    end

    def authorization
      authorize :index do
        @merchant.id == current_account.id
      end
    end
end
