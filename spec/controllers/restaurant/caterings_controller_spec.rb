require 'rails_helper'

RSpec.describe Restaurant::CateringsController, type: :controller do

  before :each do
    @restaurant = create :restaurant
    @caterings = create_list :catering, 3
  end

  describe 'GET index' do
    it 'gets full list of caterings' do
      get :index, restaurant_id: @restaurant.id, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['object']).to eq(generate_json_list @caterings)
    end
  end

  describe 'GET recent' do
    it 'gets list of active caterings' do
      @caterings[0].update_attribute :status, Catering::STATUS_DONE
      get :recent, restaurant_id: @restaurant.id, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['object']).to eq(generate_json_list @caterings[1..-1])
    end
  end

  describe 'GET show' do
    it 'gets catering details' do
      get :show, id: @caterings[0].id, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['object']).to eq(@caterings[0].as_json)
    end
  end

  describe 'format sanitization' do
    it 'fails because not using json format' do
      get :index, restaurant_id: @restaurant.id
      expect(response).to have_http_status(:not_found)
      get :recent, restaurant_id: @restaurant.id
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'parameter validation' do
    it 'fails because restaurant does not exist' do
      get :index, restaurant_id: 100, format: :json
      expect(response).to have_http_status(:not_found)
      get :recent, restaurant_id: 100, format: :json
      expect(response).to have_http_status(:not_found)
    end

    it 'fails because the catering does not exist' do
      get :show, id: 100, format: :json
      expect(response).to have_http_status(:not_found)
    end
  end
end
