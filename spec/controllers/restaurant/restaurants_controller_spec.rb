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

  describe 'GET new' do
    it 'returns ok because name is unique' do
      get :new, name: 'chicken', 
        format: :json
      expect(response).to have_http_status(:ok)
    end

    it 'returns warning message of duplicate restaurant name' do
      get :new, name: @restaurant.name, 
        format: :json
      expect(response).to have_http_status(:conflict)
      json = JSON.parse(response.body)
      expect(json['message']).to eq(generate_json_msg(
        :warning, Message::Warning::DUPLICATE_RESTAURANT_NAME))
    end
  end
end
