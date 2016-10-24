require 'rails_helper'

RSpec.describe Merchant::DropoffsController, type: :controller do
    
  context 'not logged in' do
    it 'fails authentication' do
      get :index, merchant_id: 10, format: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'logged in' do
    before :each do
      login_merchant
      @account = subject.current_account
    end

    describe 'parameter validation' do

      it 'fails because no authorization' do
        get :index, merchant_id: 100, format: :json 
        expect(response).to have_http_status(:not_found)
        post :create, merchant_id: 100, format: :json
        expect(response).to have_http_status(:not_found)
      end

      it 'lists dropoffs of current account' do
        dropoffs = create_list(:dropoff, 2, merchant_id: @account.id)
        get :index, merchant_id: @account.id, format: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['message']).to be_nil
        expect(json['object']).to eq(
          [
            { 'building_id' => dropoffs[0].building_id },
            { 'building_id' => dropoffs[1].building_id }
          ]
        )
      end

      it 'creates dropoff' do
        building = create :building
        expect {
          post :create, merchant_id: @account.id, 
            building_id: building.id, format: :json 
        }.to change(Dropoff, :count)
        expect(response).to have_http_status(:created)
      end
    end
  end
end
