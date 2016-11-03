require 'rails_helper'

RSpec.describe "Account Management", type: :request do
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
      post '/auth', username: 'david', email: 'david@gmail.com', 
        password: '12345678', password_confirmation: '12345678',
        type: Account::ACCOUNT_TYPE_MERCHANT
      email = ActionMailer::Base.deliveries.last
      confirmation_url = URI.extract email.body.encoded, /http(s)?/
      get_via_redirect confirmation_url.first
      expect(response.body).to eq('You have successfully confirmed' +
        ' the email: david@gmail.com!')
    end
  end

  describe "login POST /auth/sign_in" do
    before :each do
      post '/auth', username: 'david', email: 'david@gmail.com', 
        password: '12345678', password_confirmation: '12345678',
        type: Account::ACCOUNT_TYPE_MERCHANT
    end

    it "fails because email not confirmed" do
      post '/auth/sign_in', email: 'david@gmail.com', 
        password: '12345678', password_confirmation: '12345678'
      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json).to eq(
        {
          'success': false,
          'errors': ['A confirmation email was sent to your account' +
          " at 'david@gmail.com'. You must follow the instructions" +
          ' in the email before your account can be activated']
        }.stringify_keys!)
    end

    it "sign in account" do
      email = ActionMailer::Base.deliveries.last
      confirmation_url = URI.extract email.body.encoded, /http(s)?/
      get confirmation_url.first
      post '/auth/sign_in', email: 'david@gmail.com', 
        password: '12345678', password_confirmation: '12345678'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data'].slice 'username', 'email').to eq(
        {
          username: 'david',
          email:    'david@gmail.com'
        }.stringify_keys!)
    end
  end
end
