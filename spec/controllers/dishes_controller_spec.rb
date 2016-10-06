require 'rails_helper'

RSpec.describe Restaurant::DishesController, type: :controller do
  before :each do
    @restaurant = create :restaurant
    @dishes = create_list :dish, 5, restaurant_id: @restaurant.id
  end

  context 'not logged in' do
    describe 'signin filter' do
      it 'fails because not signed in' do
        post :create, restaurant_id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
        put :update, id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
        delete :destroy, id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'gets full list of dishes' do
        get :index, restaurant_id: @restaurant.id, format: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['object']).to eq(generate_json_list @dishes)
      end

      it 'gets dish details' do
        get :show, id: @dishes[0].id, format: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['object']).to eq(@dishes[0].as_json)
      end
    end
  end

  describe 'format sanitization' do
    it 'fails because not using json format' do
      get :index, restaurant_id: @restaurant.id
      expect(response).to have_http_status(:not_found)
      post :create, restaurant_id: @restaurant.id
      expect(response).to have_http_status(:not_found)
      put :update, id: 100
      expect(response).to have_http_status(:not_found)
      get :show, id: 100
      expect(response).to have_http_status(:not_found)
      delete :destroy, id: 100
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'logged in' do
    before :each do
      login_merchant
      @merchant = subject.current_account 
    end
    
    describe 'input validation' do
      it 'fails because merchant not authorized' do
        @restaurant.update_attribute :merchant_id, 1000
        post :create, restaurant_id: @restaurant.id, 
          price: 10.0, desc: 'asd', name: 'chicken', 
          image_url: 'http://chicken.com', format: :json
        expect(response).to have_http_status(:unauthorized)
        put :update, id: @dishes[0].id, price: 10.1, desc: 'chicken', name: 'chicken', image_url: 'http://chicken.com', format: :json
        expect(response).to have_http_status(:unauthorized)
        delete :destroy, id: @dishes[0].id, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because restaurant does not exist' do
        post :create, restaurant_id: 1000, 
          price: 10.0, desc: 'asd', name: 'chicken', 
          image_url: 'http://chicken.com', format: :json
        expect(response).to have_http_status(:not_found)
        get :index, restaurant_id: 1000, format: :json
        expect(response).to have_http_status(:not_found)
      end

      it 'fails because dishes does not exist' do
        get :show, id: 100, format: :json
        expect(response).to have_http_status(:not_found)
        put :update, id: 100, price: 10.1, desc: 'chicken',
          name: 'chicken', image_url: 'http://chicken.com', format: :json
        expect(response).to have_http_status(:not_found)
        delete :destroy, id: 100, format: :json
        expect(response).to have_http_status(:not_found)
      end

      it 'fails because url is not valid' do
        put :update, id: @dishes[0].id, price: 10.1, desc: 'chicken',
          name: 'chicken', image_url: 'file://chicken.com', format: :json
        expect(response).to have_http_status(:bad_request)
        put :update, id: @dishes[0].id, price: 10.1, desc: 'chicken',
          name: 'chicken', image_url: 'http://chicken.com' + '/a' * 300, format: :json
        expect(response).to have_http_status(:bad_request)
      end

      it 'fails because name is not valid' do
        put :update, id: @dishes[0].id, price: 10.1, desc: 'chicken',
          name: '*&^', image_url: 'http://chicken.com', format: :json
        expect(response).to have_http_status(:bad_request)
        put :update, id: @dishes[0].id, price: 10.1, desc: 'chicken',
          name: 'chicken' * 20, image_url: 'http://chicken.com', format: :json
        expect(response).to have_http_status(:bad_request)
      end

      it 'fails because description exceeds length limit' do
        put :update, id: @dishes[0].id, price: 10.1, desc: 'chicken' * 90,
          name: 'chicken', image_url: 'http://chicken.com', format: :json
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'POST create' do
      it 'fails because price not valid' do
        post :create, restaurant_id: @restaurant.id, 
          price: 'abc', desc: 'asd', name: 'chicken', 
          image_url: 'http://chicken.com', format: :json
        expect(response).to have_http_status(:bad_request)
        post :create, restaurant_id: @restaurant.id, 
          price: 0.00, desc: 'asd', name: 'chicken', 
          image_url: 'http://chicken.com', format: :json
        expect(response).to have_http_status(:bad_request)
      end

      it 'creates new dish' do
        expect {
          post :create, restaurant_id: @restaurant.id, 
            price: 10.0, desc: 'asd', name: 'chicken', 
          image_url: 'http://chicken.com', format: :json
        }.to change(Dish, :count)
        expect(response).to have_http_status(:created)
      end
    end

    describe 'PUT update' do
      it 'updates dish' do
        new_url = 'http://beef.com'
        put :update, id: @dishes[0].id, price: 10.1, desc: 'beef',
          name: 'beef', image_url:new_url, format: :json
        expect(response).to have_http_status(:ok)
        expect(@dishes[0].reload.image_url).to eq(new_url)
      end
    end

    describe 'DELETE destroy' do
      it 'removes dish' do
        delete :destroy, id: @dishes[0].id, format: :json
        expect(response).to have_http_status(:ok)
        expect(@dishes[0].reload.status).to eq(Dish::STATUS_REMOVED) 
      end
    end
  end
end
