require 'rails_helper'

RSpec.describe Merchant::ShippingsController, type: :controller do

  context 'Not logged in' do
    describe 'signin filter' do
      it 'fails because not signed in' do
        put :update_state, merchant_id: 1, id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
      
      it 'fails because not signed in' do
        post :create, merchant_id: 1, restaurant_id: 1, format: :json
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

  context 'Logged in' do
    before :each do
      @merchant = login_merchant
      @restaurant = create :restaurant, :unassociated, 
        merchant_id: @merchant.id
      @shipping = create :shipping, :unassociated, 
        restaurant_id: @restaurant.id
      @buildings = create_list :building, 2
    end
    
    let(:tomorrow) { 
        time = 1.day.from_now
        time.month * 100 + time.day 
    }

    let(:today) { 
        time = Time.now
        time.day + time.month * 100 
    }

    let(:yesterday) { 
        time = 1.day.ago
        time.month * 100 + time.day 
    }

    describe 'parameter sanitization' do
      it 'fails because restaurant not authorized' do
        @restaurant.update_attribute :merchant_id, 100
        post :create, merchant_id: @merchant.id, 
          restaurant_id: @restaurant.id, buildings: [@buildings[0].id], 
          deliver_time: 11101130, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because merchant not authorized' do
        merchant = create :merchant
        put :update_state, merchant_id: merchant.id, id: @shipping.id, 
          format: :json
        expect(response).to have_http_status(:unauthorized)
        delete :destroy, merchant_id: merchant.id, id: @shipping.id, 
          format: :json
        expect(response).to have_http_status(:unauthorized)
        post :create, merchant_id: merchant.id, 
          restaurant_id: @restaurant.id, buildings: [@buildings[0].id], 
          deliver_time: 11101130, format: :json
        expect(response).to have_http_status(:unauthorized)
        put :update, merchant_id: merchant.id, id: @shipping.id, 
          deliver_time: 11101215, format: :json
        expect(response).to have_http_status(:unauthorized)
        get :list_orders, merchant_id: merchant.id, id: @shipping.id, 
          format: :json
        expect(response).to have_http_status(:unauthorized)
      end
      
      it 'fails because shipping not authorized' do
        @restaurant.update_attribute :merchant_id, 100
        shipping = create :shipping, :unassociated, 
          restaurant_id: @restaurant.id
        put :update, merchant_id: @merchant.id, id: shipping.id,
          deliver_time: 11101215, format: :json
        expect(response).to have_http_status(:unauthorized)
        delete :destroy, merchant_id: @merchant.id, id: shipping.id, 
          format: :json
        expect(response).to have_http_status(:unauthorized)
        put :update_state, merchant_id: @merchant.id, id: shipping.id, 
          format: :json
        expect(response).to have_http_status(:unauthorized)
        get :list_orders, merchant_id: @merchant.id, id: shipping.id, 
          format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because shipping does not exist' do
        put :update, merchant_id: @merchant.id, id: 100, 
          deliver_time: 11101215, format: :json
        expect(response).to have_http_status(:not_found)
        delete :destroy, merchant_id: @merchant.id, id: 100, 
          format: :json
        expect(response).to have_http_status(:not_found)
        put :update_state, merchant_id: @merchant.id, id: 100, 
          format: :json
        expect(response).to have_http_status(:not_found)
        get :list_orders, merchant_id: @merchant.id, id: 100, 
          format: :json
        expect(response).to have_http_status(:not_found)
      end
      
      it 'fails because time format invalid' do
        post :create, merchant_id: @merchant.id, 
          restaurant_id: @restaurant.id, 
          buildings: [@buildings[0].id], deliver_time: 1216, 
          format: :json
        expect(response).to have_http_status(:bad_request)
        post :create, merchant_id: @merchant.id, 
          restaurant_id: @restaurant.id, 
          buildings: [@buildings[0].id], deliver_time: 12162500, 
          format: :json
        expect(response).to have_http_status(:bad_request)
        post :create, merchant_id: @merchant.id, 
          restaurant_id: @restaurant.id, 
          buildings: [@buildings[0].id], deliver_time: 13161100, 
          format: :json
        expect(response).to have_http_status(:bad_request)
        post :create, merchant_id: @merchant.id, 
          restaurant_id: @restaurant.id, 
          buildings: [@buildings[0].id], deliver_time: 12321200, 
          format: :json
        expect(response).to have_http_status(:bad_request)
        post :create, merchant_id: @merchant.id, 
          restaurant_id: @restaurant.id, 
          buildings: [@buildings[0].id], deliver_time: 12161210, 
          format: :json
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'PUT update' do

      it 'fails because set time in past' do
        put :update, merchant_id: @merchant.id, id: @shipping.id, 
          deliver_time: (yesterday * 10000 + 1230), format: :json
        expect(response).to have_http_status(:bad_request)
      end

      it 'fails because not enough delivery time' do
        time = 30.minute.from_now
        hour = time.hour
        min = time.min
        put :update, merchant_id: @merchant.id, id: @shipping.id, 
          deliver_time: (today * 10000 + hour * 100 + min), 
          format: :json
        expect(response).to have_http_status(:bad_request)
      end

      it 'updates the shipping time' do
        put :update, merchant_id: @merchant.id, id: @shipping.id, 
          deliver_time: (tomorrow * 10000 + 1230), format: :json
        expect(response).to have_http_status(:ok)
        expect(@shipping.reload.estimated_arrival_at).to \
          eq(Time.now.change(hour: 12, min: 30) + 1.day)
      end
    end

    describe 'PUT update_state' do
      it 'updates the shipping status' do
        @shipping.update_attribute :status, Shipping::STATUS_WAITING
        put :update_state, merchant_id: @merchant.id, id: @shipping.id, 
          format: :json
        expect(response).to have_http_status(:ok)
        expect(@shipping.reload.status).to eq(Shipping::STATUS_DEPART)
      end
    end

    describe 'POST create' do
      it 'creates the catering' do
        expect {
          post :create, merchant_id: @merchant.id, 
            restaurant_id: @restaurant.id, 
            buildings: [@buildings[0].id, @buildings[1].id], 
            deliver_time: (tomorrow * 10000 + 1215), format: :json
        }.to change(Shipping, :count).by(2)
        expect(response).to have_http_status(:created)
      end
    end

    describe 'DELETE destroy' do
      it 'destroys the catering' do
        delete :destroy, merchant_id: @merchant.id, 
          id: @shipping.id, format: :json
        expect(@shipping.reload.status).to eq(
          Shipping::STATUS_CANCELLED)
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'GET list_orders' do
      it 'lists the orders' do
        combo = create :combo
        orders = create_list :combo_order, 3, :unassociated, 
          shipping_id: @shipping.id, combo_id: combo.id
        orders[0].update_attribute :status, Order::STATUS_CHECKOUT
        orders[1].update_attribute :status, Order::STATUS_DELIVERED
        orders[2].update_attribute :status, Order::STATUS_PENDING
        get :list_orders, merchant_id: @merchant.id, id: @shipping.id, 
          format: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse response.body
        expect(json['object']).to eq(
          generate_json_list([
            {
              id: orders[0].id,
              quantity: 1,
              special_instruction: nil,
              shipping_id: @shipping.id,
              combo_id: combo.id, 
              status: Order::STATUS_CHECKOUT
            }, 
            {
              id: orders[1].id,
              quantity: 1, 
              special_instruction: nil,
              shipping_id: @shipping.id, 
              combo_id: combo.id, 
              status: Order::STATUS_DELIVERED
            }]))
      end
    end
  end
end
