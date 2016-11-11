require 'rails_helper'

RSpec.describe Merchant::ShippingsController, type: :controller do

  context 'Not logged in' do
    describe 'signin filter' do
      it 'fails because not signed in' do
        put :update, merchant_id: 1, id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context 'Logged in' do
    before :each do
      @merchant = login_merchant
      @shipping = create :shipping, merchant_id: @merchant.id
    end
    describe 'parameter sanitization' do
      it 'fails because not authorized' do
        merchant = create :merchant
        @shipping.update_attribute :merchant_id, merchant.id
        put :update, merchant_id: @merchant.id, id: @shipping.id, 
          format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because shipping does not exist' do
        put :update, merchant_id: @merchant.id, id: 100, format: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'PUT update' do
      it 'fulfills the shipping' do
        orders = create_list :order, 2
        catering = create :catering, shipping_id: @shipping.id
        orders[0].add_item 1, nil, catering
        orders[0].update_attribute :status, Order::STATUS_CHECKOUT
        orders[1].update_attribute :shipping_id, @shipping.id
        @shipping.update_attributes catering_id: catering.id,
          status: Shipping::STATUS_PICKING_UP
        put :update, merchant_id: @merchant.id, id: @shipping.id, 
          format: :json
        expect(response).to have_http_status(:ok)
        expect(orders[0].reload.status).to eq(Order::STATUS_FULFILLED)
        expect(orders[1].reload.status).to eq(Order::STATUS_UNCHECKOUT)
        expect(catering.reload.status).to eq(Catering::STATUS_DONE)
        expect(@shipping.reload.status).to eq(Shipping::STATUS_DONE)
      end
    end
  end
end
