require 'rails_helper'

RSpec.describe Merchant::UploadsController, type: :controller do

  context 'not logged in' do
    describe 'signin filter' do
      it 'fails because not signed in' do
        post :create, merchant_id: 1, file: 'whatever', format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context 'logged in' do
    before :each do
      login_merchant
      @merchant = subject.current_account 
    end

    describe 'parameter sanitization' do
      it 'fails because merchant does not exist' do
        post :create, merchant_id: 1, file: 'upload_file', 
          format: :json
        expect(response).to have_http_status(:not_found)
      end

      it 'fails because file oversized' do
        upload_file = Rack::Test::UploadedFile.new(File.open(
          Rails.root.join 'test/fixtures/oversized_file')) 
        post :create, merchant_id: @merchant.id, file: upload_file,
          format: :json
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'POST create' do
      it 'uploads the file' do
        upload_file = Rack::Test::UploadedFile.new(File.open(
          Rails.root.join 'test/fixtures/upload_file')) 
        post :create, merchant_id: @merchant.id, file: upload_file, format: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        uploaded = File.open json['object']['uri']
        expect(uploaded.read).to eq(upload_file.read)
      end
    end
  end

  
end
