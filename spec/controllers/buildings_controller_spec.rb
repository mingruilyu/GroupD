require 'rails_helper'

RSpec.describe BuildingsController, type: :controller do

  describe 'format sanitization' do
    it 'fails because not using json format' do
      get :query_by_city_company, company_id: 10, city_id: 1
      expect(response).to have_http_status(:not_found)
      get :fuzzy_query_by_address_name, query: 'Barber Street'
      expect(response).to have_http_status(:not_found)
      get :query_by_coord, lat: 10.0, lng: 10.0
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'paramter validation' do

    it 'fails because company does not exist' do
      city = create :city
      get :query_by_city_company, city_id: city.id, company_id: 100, 
        format: :json
      expect(response).to have_http_status(:not_found)
    end

    it 'fails because city does not exist' do
      company = create :company
      get :query_by_city_company, city_id: 100, company_id: company.id, 
        format: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET query' do

    before :each do
      @city = create :city
      @company = create :company
    end

    it 'gets buildings by the company and the city' do
      buildings = create_list :building, 3, company_id: @company.id, 
        city_id: @city.id
      get :query_by_city_company, city_id: @city.id, company_id: @company.id, 
        format: :json 
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['object']).to eq(generate_json_list(buildings))
    end

    it 'gets buildings by fuzzy search of address and name' do
      location = create :location, address: '4180, network circle'
      building = create :building, name: 'oracle building18', 
        location_id: location.id
      get :fuzzy_query_by_address_name, query: 'network 18', 
        format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['object']).to eq([building.as_json])

      get :fuzzy_query_by_address_name, query: '18', format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['object']).to eq([building.as_json])

      get :fuzzy_query_by_address_name, query: 'network', 
        format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['object']).to eq([building.as_json])

      get :fuzzy_query_by_address_name, query: 'oracle 18', format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['object']).to eq([building.as_json])
    end

    it 'gets buildings by coordinate' do
      location_1 = create :location, address: '4180, network circle', lat: 100.0, lng: -100.0
      building_1 = create :building, name: 'oracle building18', 
        location_id: location_1.id
      location_2 = create :location, address: '570 mill creek ln', lat: 99.7, lng: -100.3 
      building_2 = create :building, name: 'home', 
        location_id: location_2.id
      location_3 = create :location, address: '100, Barbar street, milpitas', lat: 101, lng: -99.9
      building_3 = create :building, name: 'ranch ', 
        location_id: location_3.id

      get :query_by_coord, lat: 100.0, lng: -100.2, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['object']).to eq([building_1.as_json])

      get :query_by_coord, lat: 99.8, lng: -100.1, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['object']).to eq(
        [building_1.as_json, building_2.as_json])

      get :query_by_coord, lat: 100.0, lng: -100, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['object']).to eq([building_1.as_json])

      get :query_by_coord, lat: 105, lng: -97, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['object']).to eq([])
    end
  end
end
