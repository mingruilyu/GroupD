require 'rails_helper'

RSpec.describe "Account Management", type: :request do
  context 'Not Registered' do
    describe "register POST /auth" do
      it "registers a new user" do
        expect {
          post '/auth', username: 'david', 
            email: 'david@gmail.com', password: '12345678', 
            password_confirmation: '12345678', 
            type: Account::ACCOUNT_TYPE_MERCHANT
        }.to change { ActionMailer::Base.deliveries.size }.by(1)
        expect(response).to have_http_status(200)
        json = JSON.parse response.body 
        expect(json['data'].slice 'username', 'email').to eq(
          {
            username: 'david',
            email:    'david@gmail.com'
          }.stringify_keys!
        )
      end
    end
    
    describe "confirm GET /auth/confirmation" do
      it "confirms the email" do
        request_register_account
        email = ActionMailer::Base.deliveries.last
        confirmation_url = URI.extract email.body.encoded, /http(s)?/
        puts 'confirmation_url' + confirmation_url.first
        get_via_redirect confirmation_url.first
        expect(response.body).to eq('You have successfully ' + \
          'confirmed the email: david@gmail.com!')
      end
    end


  end

  context 'Registered' do
    before :each do
      @account = register_account
    end
    context 'Not Confirmed' do
      describe "login POST /auth/sign_in" do
        it "fails because email not confirmed" do
          post '/auth/sign_in', email: @account.email, 
            password: '12345678'
          expect(response).to have_http_status(:unauthorized)
          json = JSON.parse(response.body)
          expect(json).to eq(
            {
              'success': false,
              'errors': ['A confirmation email was sent to your account' +
              " at '#{@account.email}'. You must follow the instructions" +
              ' in the email before your account can be activated']
            }.stringify_keys!)
        end
      end

      context 'confirmed' do
        before :each do
         confirm_account @account 
        end
        context 'Not Signed in' do
          describe "login POST /auth/sign_in" do
            it "sign in account" do
              post '/auth/sign_in', email: @account.email, 
                password: '12345678'
              expect(response).to have_http_status(:ok)
              json = JSON.parse(response.body)
              expect(json['data'].slice 'username', 'email').to eq(
                {
                  username: @account.username,
                  email:    @account.email
                }.stringify_keys!)
            end

            it 'fails because the password not correct' do
              post '/auth/sign_in', email: @account.email, 
                password: '123456789'
              expect(response).to have_http_status(:unauthorized)
            end
          end

          describe 'sign out DELETE /auth/sign_out' do
            it 'sign out the account' do
              token_header = login_account @account
              delete '/auth/sign_out', nil, token_header
              expect(response).to have_http_status(:ok)
              json = JSON.parse response.body
              expect(json).to eq({ success: true }.stringify_keys!)
            end
          end

          describe 'reset password email POST /auth/password' do
            it 'sends password reset link' do
              expect {
                post '/auth/password', email: @account.email, 
                  redirect_url: 'http://katering.com/auth/password/reset'
              }.to change(ActionMailer::Base.deliveries, :size)
              email = ActionMailer::Base.deliveries.last
              reset_url = URI.extract email.body.encoded, /http(s)?/
              get_via_redirect reset_url.first
              expect(response.body).to eq('This is the page for reset password')
            end
          end
        end

        context 'Signed in' do
          before :each do
            @token_header = login_account @account
          end

          describe 'validate token GET /auth/validate_token' do
            it 'validates the token and return success' do
              get '/auth/validate_token', @token_header
              expect(response).to have_http_status(:ok)
              json = JSON.parse(response.body)
              expect(json).to eq({
                success:true,
                data: @account.as_json
              }.deep_stringify_keys!)
            end

            it 'fails because token not correct' do
              @token_header[:'access-token'] = '12345678'
              get '/auth/validate_token', @token_header
              expect(response).to have_http_status(:unauthorized)
              json = JSON.parse(response.body)
              expect(json).to eq({
                success: false,
                errors: ['Invalid login credentials']
              }.deep_stringify_keys!)
            end

            it 'fails because token has expired' do
              @account.tokens.values.first['expiry'] = 2.day.ago
              @account.save!
              get '/auth/validate_token', @token_header
              expect(response).to have_http_status(:unauthorized)
              json = JSON.parse(response.body)
              expect(json).to eq({
                success: false,
                errors: ['Invalid login credentials']
              }.deep_stringify_keys!)
            end
          end

          describe 'reset password PUT /auth/password' do
            it 'resets password' do
              put '/auth/password', { password: '123456789', 
                password_confirmation: '123456789'}, @token_header 
              expect(response).to have_http_status(:ok)
              json = JSON.parse response.body
              expect(json).to eq({
                success: true,
                data: @account.reload.as_json,
                message: 'Your password has been successfully ' + \
                  'updated.'
              }.deep_stringify_keys!)
            end
          end
        end
      end
    end
  end
end
