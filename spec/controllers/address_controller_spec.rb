require 'rails_helper'

RSpec.describe AddressesController, type: :controller do
  describe 'GET edit' do
    before :each do 
      get :edit, customer_id: 0  
    end

    it 'renders the edit template' do
      expect(response).to render_template('edit')
    end
  end

  describe 'POST update' do
    before :each do
      login_customer
      xhr :put, :update, customer_id: 0, building_id: 1
    end

    it 'renders the update js template' do
      expect(response).to render_template('update')
      expect(response.content_type).to eq 'text/javascript'
    end

    it 'create update current account building' do
      expect(subject.current_account.building_id).to eq 1
    end
  end
end
