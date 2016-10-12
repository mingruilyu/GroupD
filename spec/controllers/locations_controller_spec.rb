require 'rails_helper'

RSpec.describe LocationsController, type: :controller do

  describe 'format sanitization' do
    it 'fails because not using json format' do
      get :query, query: 'whatever'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET query' do
    it 'gets infomation about the place' do
      get :query, query: 'shao mountains', format: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['object']).to eq(
        [
          { 'address' => '43749 Boscell Rd, Fremont, CA 94538, ' \
            + 'United States',
            'lat' => '37.5002431',
            'lng' => '-121.9740334'
          },
          { 'address' => '5152 Moorpark Ave #30, San Jose, CA 95129, ' \
            + 'United States',
            'lat' => '37.3089165',
            'lng' => '-121.993827'
          }
        ]
      )
    end
  end
end
