require 'rails_helper'

RSpec.describe Restaurant::RestaurantsController, type: :controller do
  before :each do
    @restaurant = create :restaurant
  end

  describe 'format sanitization' do
    it 'fails because not using json format' do
      get :show, id: @restaurant.id
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'parameter sanitization' do
    it 'fails because restaurant does not exist' do
      get :show, id: 100, format: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET show' do
    it 'gets details of the restaurant' do
      get :show, id: @restaurant.id, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['object']).to eq(@restaurant.as_json)
    end
  end
end
