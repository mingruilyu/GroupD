class Merchant::TransactionsController < Merchant::MerchantController
  def index
    transactions = Transaction.related_settled @merchant.id
    render json: Response::JsonResponse.new(transactions)
  end

  def pending
    transactions = Transaction.pending_by_receiver @merchant.id
    render json: Response::JsonResponse.new(transactions)
  end

  def update
    @transaction.authorize
    render nothing: true
  end

  def destroy
    @transaction.cancel @reason
    render nothing: true
  end

  private
    def params_sanitization
      sanitize [:index, :pending], merchant_id: :merchant
      sanitize :update, merchant_id: :merchant, id: :transaction
      sanitize :destroy, merchant_id: :merchant, id: :transaction, 
        reason: :decline_reason
    end

    def authorization
      authorize [:index, :pending] do
        @merchant.id == current_account.id
      end

      authorize [:update, :destroy] do
        @merchant.id == current_account.id && \
          @transaction.receiver_id == @merchant.id
      end
    end
end
