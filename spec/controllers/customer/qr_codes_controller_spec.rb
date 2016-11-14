require 'rails_helper'

RSpec.describe Customer::QRCodesController, type: :controller do
  context 'not logged in' do
    describe 'signin filter' do
      it 'fails because not signed in' do
        get :new, data: 'this is a test string', format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context 'logged in' do
    before :each do
      login_customer
    end

    describe 'GET new' do
      it 'generate QR code' do
        qr_image = File.open(Rails.root.join 'test/fixtures/qr_base64')
        get :new, data: 'this is a test string', format: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse response.body
        expect(json['object']).to eq(qr_image.read)
      end
    end
  end
end
