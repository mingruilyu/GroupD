require 'rails_helper'

RSpec.describe Merchant::TransactionsController, type: :controller do
  context 'not logged in' do
    describe 'signin filter' do
      it 'fails because not signed in' do
        get :index, merchant_id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because not signed in' do
        get :pending, merchant_id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because not signed in' do
        put :update, merchant_id: 1, id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because not signed in' do
        delete :destroy, merchant_id: 1, id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context 'logged in' do
    before :each do
      @merchant = login_merchant
    end

    describe 'parameter validation' do 
      it 'fails because merchant not authorized' do
        transaction = create :transaction, 
          status: Transaction::STATUS_PENDING
        merchant = create :merchant
        get :index, merchant_id: merchant.id, format: :json
        expect(response).to have_http_status(:unauthorized)
        get :pending, merchant_id: merchant.id, format: :json
        expect(response).to have_http_status(:unauthorized)
        put :update, merchant_id: merchant.id, id: transaction.id, 
          format: :json
        expect(response).to have_http_status(:unauthorized)
        delete :destroy, merchant_id: merchant.id, id: transaction.id, 
          reason: Transaction::DECLINE_AMOUNT_INCORRECT, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because transaction does not exist' do
        put :update, merchant_id: @merchant.id, id: 100, format: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'GET index' do
      it 'get the settled transaction history' do
        pending_transactions = create_list :transaction, 2, 
          receiver_id: @merchant.id, 
          status: Transaction::STATUS_PENDING
        receive_transactions = create_list :transaction, 2, 
          receiver_id: @merchant.id
        send_transactions = create_list :transaction, 2, 
          sender_id: @merchant.id, receiver_id: 100
        get :index, merchant_id: @merchant.id, format: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        json_list = generate_json_list(receive_transactions) + \
          generate_json_list(send_transactions)
        expect(json['object']).to eq(
          json_list.sort_by! do |item|
            item[:time]
          end
        )
      end
    end

    describe 'GET pending' do
      it 'gets the pending transactions' do
        settled_transactions = create_list :transaction, 2, 
          receiver_id: @merchant.id
        pending_transactions = create_list :transaction, 2, 
          receiver_id: @merchant.id, 
          status: Transaction::STATUS_PENDING
        get :pending, merchant_id: @merchant.id, format: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['object']).to eq(
          generate_json_list(pending_transactions).sort_by! do |item|
            item[:time]
          end
        )
      end
    end

    describe 'PUT update' do
      it 'authorizes the transaction' do
        pending_transaction = create :transaction, 
          receiver_id: @merchant.id, 
          status: Transaction::STATUS_PENDING
        debt = Debt.create loaner_id: @merchant.id, 
          debtor_id: pending_transaction.sender_id, amount: 0
        put :update, merchant_id: @merchant.id, 
          id: pending_transaction.id, format: :json
        expect(response).to have_http_status(:ok)
        expect(pending_transaction.reload.status).to eq(
          Transaction::STATUS_DONE)
        expect(debt.reload.amount).to eq(-10)
      end

      it 'fails because transation not authorizable' do
        transaction = create :transaction, receiver_id: @merchant.id
        put :update, merchant_id: @merchant.id, id: transaction.id, 
          format: :json
        expect(response).to have_http_status(:found)
        json = JSON.parse(response.body)
        expect(json['message']).to eq(generate_json_msg(:error,
          {'status': [I18n.t('error.TRANSACTION_NOT_AUTHORIZABLE')]}))
      end
    end

    describe 'DELETE destroy' do
      it 'declines the transaction' do
        pending_transaction = create :transaction, 
          receiver_id: @merchant.id, 
          status: Transaction::STATUS_PENDING
        delete :destroy, merchant_id: @merchant.id,
          id: pending_transaction.id, 
          reason: Transaction::DECLINE_AMOUNT_INCORRECT,
          format: :json
        expect(response).to have_http_status(:ok)
        expect(pending_transaction.reload.status).to eq(
          Transaction::STATUS_CANCELLED)
        expect(pending_transaction.note).to eq(
          I18n.t 'error.DECLINE_AMOUNT_INCORRECT')
      end

      it 'fails because the transaction is not cancellable' do
        transaction = create :transaction
        delete :destroy, merchant_id: @merchant.id, 
          id: transaction.id, 
          reason: Transaction::DECLINE_AMOUNT_INCORRECT,
          format: :json
        expect(response).to have_http_status(:found)
        json = JSON.parse(response.body)
        expect(json['message']).to eq(generate_json_msg(:error,
          {'status': [I18n.t('error.TRANSACTION_NOT_CANCELLABLE')]}))
      end
    end
  end
end
