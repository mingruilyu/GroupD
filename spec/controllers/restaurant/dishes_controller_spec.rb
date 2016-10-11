require 'rails_helper'

RSpec.describe Restaurant::DishesController, type: :controller do

  before :each do
    @restaurant = create :restaurant
    @dishes = create_list :dish, 2, restaurant_id: @restaurant.id
  end

  describe 'GET index' do
    it 'gets full list of dishes' do
      get :index, restaurant_id: @restaurant.id, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['object']).to eq(generate_json_list @dishes)
    end
  end

  describe 'GET show' do
    it 'gets dish details' do
      get :show, id: @dishes[0].id, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['object']).to eq(@dishes[0].as_json)
    end
  end

  describe 'format sanitization' do
    it 'fails because not using json format' do
      get :index, restaurant_id: @restaurant.id
      expect(response).to have_http_status(:not_found)
      get :show, id: 100
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'input validation' do
    it 'fails because restaurant does not exist' do
      get :index, restaurant_id: 1000, format: :json
      expect(response).to have_http_status(:not_found)
    end

    it 'fails because dish does not exist' do
      get :show, id: 100, format: :json
      expect(response).to have_http_status(:not_found)
    end
  end
end
