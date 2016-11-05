require 'rails_helper'

RSpec.describe Merchant::DebtsController, type: :controller do
  context 'not logged in' do
    describe 'signin filter' do
      it 'fails because not signed in' do
        get :index, merchant_id: 1, format: :json
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
        merchant = create :merchant
        get :index, merchant_id: merchant.id, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because merchant does not exist' do
        get :index, merchant_id: 100, format: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'GET index' do
      it 'gets list of debts for the merchant' do
        debts = create_list :debt, 2, loaner_id: @merchant.id
        get :index, merchant_id: @merchant.id, format: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['object']).to eq(generate_json_list debts)
      end
    end
  end
end
