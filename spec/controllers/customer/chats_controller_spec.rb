require 'rails_helper'

RSpec.describe Customer::ChatsController, type: :controller do
  before :each do
    @parameters = YAML.load File.open(
      Rails.root.join 'test/fixtures/wechat_post_params.yml') 
    @parameters['format'] = :xml
  end
  describe 'parameter validation' do
    it 'fails because signature does not match'  do
      @parameters['nonce'] = '123456789'
      post :chat, 'nothing there', @parameters
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST chat' do
    it 'registers the new user' do
      subscribe = (File.open Rails.root.join( 
        'test/fixtures/wechat_post_subscribe')).read
      expect {
        post :chat, subscribe, @parameters
      }.to change(Customer, :count)
      expect(response).to have_http_status(:ok)
      xml = Hash.from_xml(response.body).deep_symbolize_keys
      expect(xml).to eq({
          xml:
          {
            ToUserName: "123", 
            FromUserName: '404844425', 
            CreateTime: Time.now.to_i.to_s, 
            MsgType: 'text', 
            Content: 'Thank you for registering for Katering service!'
          }})
    end
  end
end
