require 'rails_helper'

RSpec.describe Merchant::DishesController, type: :controller do

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
      @dishes = create_list :dish, 3, restaurant_id: @restaurant.id
    end
    
    let(:url) { 'http://chicken.com' }
    
    describe 'input validation' do
      it 'fails because merchant not authorized' do
        @restaurant.update_attribute :merchant_id, 1000
        post :create, merchant_id: @merchant.id, 
          restaurant_id: @restaurant.id, price: 10.0, desc: 'asd', 
          name: 'chicken', image_url: url, format: :json
        expect(response).to have_http_status(:unauthorized)
        put :update, merchant_id: @merchant.id, id: @dishes[0].id, 
          price: 10.1, desc: 'chicken', name: 'chicken', 
          image_url: url, format: :json
        expect(response).to have_http_status(:unauthorized)
        delete :destroy, merchant_id: @merchant.id, id: @dishes[0].id, 
          format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because restaurant does not exist' do
        post :create, merchant_id: @merchant.id, restaurant_id: 1000, 
          price: 10.0, desc: 'asd', name: 'chicken', image_url: url, 
          format: :json
        expect(response).to have_http_status(:not_found)
      end

      it 'fails because dish does not exist' do
        put :update, merchant_id: @merchant.id, id: 100, price: 10.1, 
          desc: 'chicken', name: 'chicken', image_url: url, 
          format: :json
        expect(response).to have_http_status(:not_found)
        delete :destroy, merchant_id: @merchant.id, id: 100, 
          format: :json
        expect(response).to have_http_status(:not_found)
      end

      it 'fails because url is not valid' do
        put :update, merchant_id: @merchant.id, id: @dishes[0].id, 
          price: 10.1, desc: 'chicken', name: 'chicken', 
          image_url: 'file://chicken.com', format: :json
        expect(response).to have_http_status(:bad_request)
        put :update, merchant_id: @merchant.id, id: @dishes[0].id, 
          price: 10.1, desc: 'chicken', name: 'chicken',
          image_url: url + '/a' * 300, format: :json
        expect(response).to have_http_status(:bad_request)
      end

      it 'fails because name is not valid' do
        put :update, merchant_id: @merchant.id, id: @dishes[0].id, 
          price: 10.1, desc: 'chicken', name: '*&^', image_url: url, 
          format: :json
        expect(response).to have_http_status(:bad_request)
        put :update, merchant_id: @merchant.id, id: @dishes[0].id, 
          price: 10.1, desc: 'chicken', name: 'chicken' * 20, 
          image_url: url, format: :json
        expect(response).to have_http_status(:bad_request)
      end

      it 'fails because description exceeds length limit' do
        put :update, merchant_id: @merchant.id, id: @dishes[0].id, 
          price: 10.1, desc: 'chicken' * 90, name: 'chicken',      
          image_url: url, format: :json
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'POST create' do
      it 'fails because price not valid' do
        url
        post :create, merchant_id: @merchant.id, 
          restaurant_id: @restaurant.id, price: 'abc', desc: 'asd', 
          name: 'chicken', image_url: url, format: :json
        expect(response).to have_http_status(:bad_request)
        post :create, merchant_id: @merchant.id, 
          restaurant_id: @restaurant.id, price: 0.00, desc: 'asd', 
          name: 'chicken', image_url: url, format: :json
        expect(response).to have_http_status(:bad_request)
      end

      it 'creates new dish' do
        expect {
          post :create, merchant_id: @merchant.id, 
            restaurant_id: @restaurant.id, price: 10.0, desc: 'asd', 
            name: 'chicken', image_url: url, format: :json
        }.to change(Dish, :count)
        expect(response).to have_http_status(:created)
      end
    end

    describe 'PUT update' do
      it 'updates dish' do
        new_url = 'http://beef.com'
        put :update, merchant_id: @merchant.id, id: @dishes[0].id,
          price: 10.1, desc: 'beef', name: 'beef', image_url:new_url, 
          format: :json
        expect(response).to have_http_status(:ok)
        expect(@dishes[0].reload.image_url).to eq(new_url)
      end
    end

    describe 'DELETE destroy' do
      it 'removes dish' do
        delete :destroy, merchant_id: @merchant.id, id: @dishes[0].id, 
          format: :json
        expect(response).to have_http_status(:ok)
        expect(@dishes[0].reload.status).to eq(Dish::STATUS_REMOVED) 
      end
    end
  end
end
