class Account::CellphonesController < ApplicationController
  
  def create
    token = Cellphone.create_cellphone @number, @account.id
    render json: Response::JsonResponse.new(token)
  end

  def resend
    token = @cellphone.resend_confirmation
    render json: Response::JsonResponse.new(token)
  end

  def update
    @cellphone.verify_token @token, @account
    render nothing: true
  end
  
  private

    def params_sanitization
      sanitize :create, account_id: :account, number: :number
      sanitize :resend, account_id: :account, id: :cellphone
      sanitize :update, account_id: :account,id: :cellphone, token: :confirmation_token
    end

    def authorization
      authorize :create do
        current_account.id == @account.id
      end
      authorize [:resend, :update] do
        current_account.id == @account.id && \
          @cellphone.account_id == @account.id
      end
    end
end
