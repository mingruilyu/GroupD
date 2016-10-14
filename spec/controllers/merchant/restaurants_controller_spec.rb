require 'rails_helper'

RSpec.describe Merchant::RestaurantsController, type: :controller do

  context 'not logged in' do
    describe 'signin filter' do
      it 'fails because not signed in' do
        get :index, merchant_id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
      it 'fails because not signed in' do
        post :create, merchant_id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
      it 'fails because not signed in' do
        put :update, id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
      it 'fails because not signed in' do
        delete :destroy, id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'format sanitization' do
    it 'fails because not using json format' do
      get :index, merchant_id: 1
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'logged in' do
    before :each do
      login_merchant
      @merchant = subject.current_account 
      @restaurant = create :restaurant, merchant_id: @merchant.id
      @category = create :category
      @city = create :city 
    end

    describe 'input validation' do
      it 'fails because merchant not authorized' do
        merchant = create :merchant
        post :create, merchant_id: merchant.id, 
          name: @restaurant.name, 
          location_id: @restaurant.location_id, 
          image_url: @restaurant.image_url, 
          category_id: @category.id, city_id: @city.id, format: :json
        expect(response).to have_http_status(:unauthorized)
        get :index, merchant_id: merchant.id, format: :json
        expect(response).to have_http_status(:unauthorized)

        @restaurant.update_attribute :merchant_id, 100
        put :update, merchant_id: merchant.id, id: @restaurant.id, 
          name: @restaurant.name, location_id: @restaurant.location_id, 
          image_url: @restaurant.image_url, format: :json
        expect(response).to have_http_status(:unauthorized)
        delete :destroy, merchant_id: merchant.id, id: @restaurant.id, 
          format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because merchant does not exist' do
        post :create, merchant_id: 100, name: @restaurant.name, 
          location_id: @restaurant.location_id, 
          image_url: @restaurant.image_url, 
          category_id: @category.id, city_id: @city.id, format: :json
        expect(response).to have_http_status(:not_found)
        get :index, merchant_id: 100, format: :json
        expect(response).to have_http_status(:not_found)
      end

      it 'fails because restaurant does not exist' do
        put :update, merchant_id: @merchant.id, id: 100, 
          name: 'chicken', location_id: @restaurant.location_id,
          image_url: @restaurant.image_url, format: :json
        expect(response).to have_http_status(:not_found)
        delete :destroy, merchant_id: @merchant.id, id: 100, 
          format: :json
        expect(response).to have_http_status(:not_found)
      end

      it 'fails because url is not valid' do
        put :update, id: @restaurant.id, name: 'chicken', 
          location_id: @restaurant.location_id,
          image_url: 'not_http', format: :json
        expect(response).to have_http_status(:bad_request)
        put :update, id: @restaurant.id, name: 'chicken', 
          location_id: @restaurant.location_id,
          image_url: 'http://chicken.com' + '/a' * 300, format: :json
        expect(response).to have_http_status(:bad_request)
      end

      it 'fails because name is not valid' do
        put :update, id: @restaurant.id, name: '^&%', 
          location_id: @restaurant.location_id,
          image_url: 'not_http', format: :json
        expect(response).to have_http_status(:bad_request)
        put :update, id: @restaurant.id, name: 'chicken' * 20, 
          location_id: @restaurant.location_id,
          image_url: 'not_http', format: :json
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'POST create' do
      it 'fails because name not unique' do
        post :create, merchant_id: @merchant.id, 
          name: @restaurant.name, 
          location_id: @restaurant.location_id, 
          image_url: @restaurant.image_url, 
          category_id: @category.id, city_id: @city.id, format: :json
        expect(response).to have_http_status(:bad_request)
      end

      it 'creates new restaurant' do
        expect {
          post :create, merchant_id: @merchant.id, 
          name: 'chicken', location_id: @restaurant.location_id,
          image_url: @restaurant.image_url, 
          category_id: @category.id, city_id: @city.id, format: :json
        }.to change(Restaurant, :count)
        expect(response).to have_http_status(:created)
      end
    end

    describe 'PUT update' do
      it 'updates restaurant' do
        new_url = 'http://www.shanghai.com'
        put :update, merchant_id: @merchant.id, id: @restaurant.id, 
          name: 'chicken', location_id: @restaurant.location_id,
          image_url: new_url, format: :json
        expect(response).to have_http_status(:ok)
        expect(@restaurant.reload.image_url).to eq(new_url)
      end
    end

    describe 'GET index' do
      it 'get a list of open restaurant' do
        restaurant = create :restaurant, name: 'shancheng', 
          status: Restaurant::STATUS_CLOSED 
        get :index, merchant_id: @merchant.id, format: :json 
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['object']).to eq([@restaurant.as_json])
      end
    end

    describe 'DELETE destroy' do
      it 'destroies the restauarant' do
        delete :destroy, merchant_id: @merchant.id, 
          id: @restaurant.id, format: :json
        expect(response).to have_http_status(:ok)
        expect(@restaurant.reload.status).to eq(
          Restaurant::STATUS_CLOSED)
      end
    end
  end
end
