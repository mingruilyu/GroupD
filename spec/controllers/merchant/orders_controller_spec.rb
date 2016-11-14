require 'rails_helper'

RSpec.describe Merchant::OrdersController, type: :controller do
    
  context 'not logged in' do
    it 'fails authentication' do
      put :update, id: 10, format: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'logged in' do
    before :each do
      @account = login_merchant
    end

    describe 'parameter validation' do

      it 'fails because not authorized' do
        restaurant = create :restaurant, merchant_id: 100
        order = create :order, restaurant_id: restaurant.id
        put :update, id: order.id, format: :json 
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because order does not exist' do
        put :update, id: 100, format: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'PUT update' do
      it 'updates order' do
        restaurant = create :restaurant, merchant_id: @account.id
        order = create :order, restaurant_id: restaurant.id
        put :update, id: order.id, format: :json
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
