require 'rails_helper'

RSpec.describe "Account Management", type: :request do
  describe "POST /auth" do
    it "registers a new user" do
      expect {
        post '/auth', username: 'david', 
          email: 'david@gmail.com', password: '12345678', 
          password_confirmation: '12345678'
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

end
