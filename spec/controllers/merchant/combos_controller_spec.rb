require 'rails_helper'

RSpec.describe Merchant::CombosController, type: :controller do

  context 'not logged in' do
    describe 'signin filter' do
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

  context 'logged in' do
    before :each do
      login_merchant
      @merchant = subject.current_account
      @restaurant = create :restaurant, merchant_id: @merchant.id
      @combo = create :combo, restaurant_id: @restaurant.id
      @dishes = create_list :dish, 2, restaurant_id: @restaurant.id
    end

    let(:url) { 'http://shanghai.combo.com' }

    describe 'format sanitization' do
      it 'fails because not using json format' do
        post :create, merchant_id: 1, restaurant_id: @restaurant.id
        expect(response).to have_http_status(:not_found)
        put :update, merchant_id: 1, id: @combo.id
        expect(response).to have_http_status(:not_found)
        delete :destroy, merchant_id: 1, id: @combo.id
        expect(response).to have_http_status(:not_found)
        get :show, merchant_id: 1, id: @combo.id
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'parameter validation' do
      it 'fails because merchant not authorized' do
        @restaurant.update_attribute :merchant_id, 100
        post :create, merchant_id: @merchant.id, price: 10.0,
          restaurant_id: @restaurant.id, image_url: url,
          dishes: [@dishes[0].id, @dishes[1].id], format: :json
        expect(response).to have_http_status(:unauthorized)
        put :update, merchant_id: @merchant.id, id: @combo.id, 
          dishes: [@dishes[0].id, @dishes[1].id], price: 10.0, 
          image_url: url, format: :json
        expect(response).to have_http_status(:unauthorized)
        get :show, merchant_id: @merchant.id, id: @combo.id, 
          format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because dish does not belong to the merchant' do
        @restaurant.update_attribute :merchant_id, @merchant.id
        @dishes[0].update_attribute :restaurant_id, 100
        put :update, merchant_id: @merchant.id, id: @combo.id, 
          dishes: [@dishes[0].id, @dishes[1].id], price: 10.0, 
          image_url: url, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because dish count exceeds limit' do
        post :create, merchant_id: @merchant.id, 
          restaurant_id: @restaurant.id, dishes: [1, 2, 3, 4, 5, 6], 
          price: 10.0, image_url: url, format: :json
        expect(response).to have_http_status(:bad_request)
      end

      it 'fails because the combo does not exist' do
        put :update, merchant_id: @merchant.id, id: 100, price: 10.10, 
          dishes: [@dishes[0].id], image_url: url, format: :json
        expect(response).to have_http_status(:not_found)
        delete :destroy, merchant_id: @merchant.id, id: 100, 
          format: :json
        expect(response).to have_http_status(:not_found)
        get :show, merchant_id: @merchant.id, id: 100, format: :json
        expect(response).to have_http_status(:not_found)
      end

      it 'fails because the dishes does not exist' do
        put :update, merchant_id: @merchant.id, id: @combo.id, 
          price: 10.10, dishes: [100], image_url: url, format: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'POST create' do
      it 'create the combo' do
        post :create, merchant_id: @merchant.id, price: 10.0,
          restaurant_id: @restaurant.id, image_url: url, 
          dishes: [@dishes[0].id, @dishes[1].id], format: :json
        expect(response).to have_http_status(:created)
      end

      it 'fails because the price not valid' do
        post :create, merchant_id: @merchant.id, price: 'asd',
          restaurant_id: @restaurant.id, image_url: url,
          dishes: [@dishes[0].id, @dishes[1].id], format: :json
        expect(response).to have_http_status(:bad_request)
        post :create, merchant_id: @merchant.id, price: 0.0,
          restaurant_id: @restaurant.id, image_url: url,
          dishes: [@dishes[0].id, @dishes[1].id], format: :json
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'PUT update' do
      it 'updates the combo' do
        put :update, merchant_id: @merchant.id, id: @combo.id, 
          price: 10.10, dishes: [@dishes[0].id], image_url: url,
          format: :json
        expect(response).to have_http_status(:ok)
        expect(@combo.reload.dish_2).to eq(nil)
        expect(@combo.dish_3).to eq(nil)
        expect(@combo.dish_4).to eq(nil)
        expect(@combo.dish_5).to eq(nil)
        expect(@combo.price).to eq(10.10)
      end
    end

    describe 'DELETE destroy' do
      it 'changes status of the combo' do
        expect{
          delete :destroy, merchant_id: @merchant.id, id: @combo.id, 
            format: :json
        }.to change(Combo, :count).by(-1)
        expect(response).to have_http_status(:ok)
      end

      it 'changes status of the combo and returns a list of catering
        needed to be cancelled' do
        catering = create :catering, combo_id: @combo.id
        delete :destroy, merchant_id: @merchant.id, id: @combo.id, 
          format: :json
        expect(response).to have_http_status(:ok)
        expect(@combo.reload.status).to eq(
          Combo::STATUS_CANCELLED)
        json = JSON.parse(response.body)
        expect(json['object']).to eq([catering.as_json])
      end
    end

    describe 'GET show' do
      it 'shows the ordering status of the combo and the related 
        caterings' do
        caterings = create_list :catering, 3, combo_id: @combo.id    
        caterings[0].update_attribute :status, Catering::STATUS_DONE
        caterings[1].update_attribute :order_count, 3
        get :show, merchant_id: @merchant.id, id: @combo.id, 
          format: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['object']).to eq(generate_json_list(
          caterings[1..2]))
      end
    end

    describe 'GET recent' do
      it 'shows the list of combos that have active caterings' do
        catering = create :catering, combo_id: @combo.id
        get :recent, merchant_id: @merchant.id, 
          restaurant_id: @restaurant.id, format: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['object']).to eq([@combo.as_json])
      end
    end
  end
end
