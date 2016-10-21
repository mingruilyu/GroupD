require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do

  describe 'format sanitization' do
    it 'fails because not using json format' do
      get :query, name: 'whatever'
      expect(response).to have_http_status(:not_found)
      get :index, city_id: 1
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET index' do
    before :each do
      @city = create :city
      @companies = create_list :company, 3
    end

    it 'gets list of companies by city' do
      building_1 = create :building, company_id: @companies[0].id, 
        city_id: @city.id
      building_2 = create :building, company_id: @companies[1].id, 
        city_id: @city.id
      building_3 = create :building, company_id: @companies[2].id, 
        city_id: 100

      get :index, city_id: @city.id, format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse response.body
      expect(json['object']).to eq(generate_json_list(
        @companies[0..1]))
    end

    it 'gets list of companies matching by name' do
      amazon = create :company, name: 'amazon'
      get :query, name: 'oracle', format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse response.body
      expect(json['object']).to eq(generate_json_list(
        @companies))
    end
  end
end
