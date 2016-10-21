require 'rails_helper'

RSpec.describe Account::CellphonesController, type: :controller do
  context 'not logged in' do
    describe 'signin filter' do
      it 'fails because not signed in' do
        post :create, account_id: 1, number: 8058955364,
          format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because not signed in' do
        post :resend, account_id: 1, id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because not signed in' do
        put :update, account_id: 1, id: 1, token: 123456, 
          format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context 'logged in' do

    before :each do
      login_merchant
      @merchant = subject.current_account
      @cellphone = create :cellphone, account_id: @merchant.id,
        confirmation_token: '123456', 
        confirmation_sent_at: 100.second.ago
    end

    describe 'format sanitization' do
      it 'fails because not using json format' do
        post :create, account_id: 1, number: 8058055364
        expect(response).to have_http_status(:not_found)
        post :create, account_id: 1, cellphone_id: 1
        expect(response).to have_http_status(:not_found)
        put :update, account_id: 1, id: 100
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'input validation' do
      it 'fails because account not authorized' do
        account = create :merchant
        post :create, account_id: account.id, number: 8058055364,
          format: :json
        expect(response).to have_http_status(:unauthorized)
        post :resend, account_id: account.id, id: @cellphone.id,
          format: :json
        expect(response).to have_http_status(:unauthorized)
        put :update, account_id: account.id, id: @cellphone.id, 
          token: '123456', format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because cellphone does to belongs to the account' do
        cellphone = create :cellphone
        post :resend, account_id: @merchant.id, id: cellphone.id,
          format: :json
        expect(response).to have_http_status(:unauthorized)
        post :update, account_id: @merchant.id,id: cellphone.id,
          token: '123456', format: :json
      end
    end

    describe 'POST create' do
      it 'fails because cellphone number is used' do
        post :create, account_id: @merchant.id, 
          number: @cellphone.number, format: :json
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['message']).to eq(generate_json_msg(:error,
          { 'number': [I18n.t('error.NUMBER_USED')] }))
      end

      it 'creates cellphone number' do
        expect {
          post :create, account_id: @merchant.id, 
            number: '8058955564', format: :json 
        }.to change(Cellphone, :count)
        expect(response).to have_http_status(:ok)
        new_cellphone = Cellphone.find_by_number '8058955564'
        json = JSON.parse(response.body)
        expect(json['object']).to eq(
          new_cellphone.confirmation_token)
      end
    end

    describe 'POST resend' do
      it 'fails because cellphone is already confirmed' do
        @cellphone.update_attribute :confirmed_at, Time.now
        post :resend, account_id: @merchant.id, id: @cellphone.id,
          format: :json 
        expect(response).to have_http_status(:found)
        json = JSON.parse(response.body)
        expect(json['message']).to eq(generate_json_msg(:error,
          { 'confirm': [I18n.t('error.DUPLICATE_CONFIRMATION')] }))
      end

      it 'fails because resending to frequently' do
        @cellphone.update_attribute :confirmation_sent_at,
          10.second.ago 
        post :resend, account_id: @merchant.id, id: @cellphone.id,
          format: :json
        expect(response).to have_http_status(:found)
        json = JSON.parse(response.body)
        expect(json['message']).to eq(generate_json_msg(:error, 
          { 'confirm': [I18n.t('error.RESEND_TOO_FREQUENTLY')] }))
      end
    end

    describe 'PUT update' do
      it 'fails because cellphone is already confirmed' do
        @cellphone.update_attribute :confirmed_at,  Time.now
        put :update, account_id: @merchant.id, id: @cellphone.id, 
          token: '123456', format: :json
        expect(response).to have_http_status(:found)
        json = JSON.parse(response.body)
        expect(json['message']).to eq(generate_json_msg(:error,
          { 'confirm': [I18n.t('error.DUPLICATE_CONFIRMATION')] }))
      end

      it 'fails because the token is not right' do
        put :update, account_id: @merchant.id, id: @cellphone.id, 
          token: '456789', format: :json
        expect(response).to have_http_status(:found)
        json = JSON.parse(response.body)
        expect(json['message']).to eq(generate_json_msg(:error,
          { 'confirm': [I18n.t('error.WRONG_TOKEN')] }))
      end

      it 'fails because the token has expired' do
        @cellphone.update_attribute :confirmation_sent_at, 1.hour.ago
        put :update, account_id: @merchant.id, id: @cellphone.id, 
          token: @cellphone.confirmation_token, format: :json
        expect(response).to have_http_status(:found)
        json = JSON.parse(response.body)
        expect(json['message']).to eq(generate_json_msg(:error, 
          { 'confirm': [I18n.t('error.CONFIRMATION_EXPIRED')] }))
      end

      it 'confirms the cellphone' do
        put :update, account_id: @merchant.id, id: @cellphone.id, 
          token: @cellphone.confirmation_token, format: :json
        expect(response).to have_http_status(:ok)
        expect(@merchant.reload.cellphone_id).to eq(@cellphone.id)
      end
    end
  end
end
