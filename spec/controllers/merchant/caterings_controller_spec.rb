require 'rails_helper'

RSpec.describe Merchant::CateringsController, type: :controller do

  before :each do
    @merchant = create :merchant
    @restaurant = create :restaurant, merchant_id: @merchant.id
    @caterings = create :catering
    @combo = @caterings.combo
    @buildings = create_list :building, 2
  end

  context 'not logged in' do
    describe 'signin filter' do
      it 'fails because not signed in' do
        post :create, merchant_id: 1, restaurant_id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
        put :update, merchant_id: 1, id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
        delete :destroy, merchant_id: 1, id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context 'logged in' do
    before :each do
      login_merchant
    end

    let(:tomorrow) { time = (Time.now + 1.day)
      time.month * 100 + time.day }
    let(:today) { time = Time.now
      time.day + Time.now.month * 100 }
    let(:yesterday) { time = Time.now - 1.day
      time.month * 100 + time.day }

    describe 'format sanitization' do
      it 'fails because not using json format' do
        post :create, merchant_id: 1, restaurant_id: @restaurant.id
        expect(response).to have_http_status(:not_found)
        put :update, merchant_id: 1, id: 100
        expect(response).to have_http_status(:not_found)
        delete :destroy, merchant_id: 1, id: 100
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'parameter validation' do
      it 'fails because merchant not authorized' do
        @restaurant.update_attribute :merchant_id, 100
        post :create, merchant_id: @merchant.id, 
          restaurant_id: @restaurant.id, combo_id: @combo.id, 
          buildings: [@buildings[0].id], delivery_time_int: 1215, 
          deadline_int: 1130, date: 1010, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because the catering does not exist' do
        put :update, merchant_id: @merchant.id, id: 100, date: 1010, 
          delivery_time_int: 1215, deadline_int: 1130, format: :json
        expect(response).to have_http_status(:not_found)
        delete :destroy, merchant_id: @merchant.id, id: 100, 
          format: :json
        expect(response).to have_http_status(:not_found)
      end

      it 'fails because time format invalid' do
        post :create, merchant_id: @merchant.id, 
          restaurant_id: @restaurant.id, combo_id: @combo.id, 
          buildings: [@buildings[0].id], delivery_time_int: 1216, 
          deadline_int: 1130, date: 1010, format: :json
        expect(response).to have_http_status(:bad_request)
        post :create, merchant_id: @merchant.id, 
          restaurant_id: @restaurant.id, combo_id: @combo.id, 
          buildings: [@buildings[0].id], delivery_time_int: 4000, 
          deadline_int: 1130, date: 1010, format: :json
        expect(response).to have_http_status(:bad_request)
      end

      it 'fails because date format invalid' do
        post :create, merchant_id: @merchant.id, 
          restaurant_id: @restaurant.id, combo_id: @combo.id, 
          buildings: [@buildings[0].id], delivery_time_int: 1215, 
          deadline_int: 1130, date: 1310, format: :json
        expect(response).to have_http_status(:bad_request)
        post :create, merchant_id: @merchant.id, 
          restaurant_id: @restaurant.id, combo_id: @combo.id, 
          buildings: [@buildings[0].id], delivery_time_int: 1215, 
          deadline_int: 1130, date: 940, format: :json
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'PUT update' do
      it 'fails because set time in past' do
        put :update, merchant_id: @merchant.id, id: @caterings.id, 
          delivery_time_int: 1215, deadline_int: 1130, 
          date: yesterday, format: :json
        expect(response).to have_http_status(:bad_request)
      end

      it 'fails because not enough delivery time' do
        put :update, merchant_id: @merchant.id, id: @caterings.id, 
          delivery_time_int: 1215, deadline_int: 1215, 
          date: tomorrow, format: :json
        expect(response).to have_http_status(:bad_request)
      end

      it 'fails because not enough order time' do
        time = Time.now + 30.minute
        deadline = time.hour * 100 + time.min / 15 * 15 
        time = Time.now + 1.hour
        delivery = time.hour * 100 + time.min / 15 * 15
        put :update, merchant_id: @merchant.id, id: @caterings.id, 
          delivery_time_int: delivery, deadline_int: deadline, 
          date: today, format: :json
        expect(response).to have_http_status(:bad_request)
      end

      it 'updates the catering time' do
        put :update, merchant_id: @merchant.id, id: @caterings.id, 
          delivery_time_int: 1215, deadline_int: 1130, 
          date: tomorrow, format: :json
        expect(response).to have_http_status(:ok)
        expect(@caterings.reload.available_until).to \
          eq(Time.now.change(hour: 11, min: 30) + 1.day)
      end
    end

    describe 'POST create' do
      it 'creates the catering' do
        expect {
          post :create, merchant_id: @merchant.id, 
            restaurant_id: @restaurant.id, combo_id: @combo.id, 
            buildings: [@buildings[0].id], delivery_time_int: 1215, 
            deadline_int: 1130, date: 1210, format: :json
        }.to change(Catering, :count).and change(Shipping, :count)
        expect(response).to have_http_status(:created)
      end

      it 'fails because the combo does not belong to restaurant' do
        @combo.update_attribute :restaurant_id, 100 
        post :create, merchant_id: @merchant.id, 
          restaurant_id: @restaurant.id, combo_id: @combo.id, 
          buildings: [@buildings[0].id], delivery_time_int: 1215, 
          deadline_int: 1130, date: 1210, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe 'DELETE destroy' do
      it 'destroys the catering' do
        delete :destroy, merchant_id: @merchant.id, 
          id: @caterings.id, format: :json
        expect(@caterings.reload.status).to eq(
          Catering::STATUS_CANCELLED)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
