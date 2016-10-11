require 'rails_helper'

RSpec.describe Restaurant::CombosController, type: :controller do

  before :each do
    @restaurant = create :restaurant
    @combos = create_list :combo, 2, restaurant_id: @restaurant.id
  end

  describe 'GET index' do
    it 'gets full list of combos' do
      get :index, restaurant_id: @restaurant.id, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['object']).to eq(generate_json_list @combos)
    end

    it 'gets combo details' do
      get :show, id: @combos[0].id, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['object']).to eq(@combos[0].as_json)
    end
  end

  describe 'format sanitization' do
    it 'fails because not using json format' do
      get :index, restaurant_id: @restaurant.id
      expect(response).to have_http_status(:not_found)
      get :show, id: 1
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'parameter validation' do
    it 'fails because restaurant does not exist' do
      get :index, restaurant_id: 100, format: :json
      expect(response).to have_http_status(:not_found)
    end

    it 'fails because the combo does not exist' do
      get :show, id: 100, format: :json
      expect(response).to have_http_status(:not_found)
    end
  end
end
