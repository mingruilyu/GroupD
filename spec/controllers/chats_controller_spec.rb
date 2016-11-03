require 'rails_helper'

RSpec.describe ChatsController, type: :controller do
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

    it 'gets nothing because address not set' do
      customer = omniauth_register_account
      customer.update_attribute :building_id, nil
      menu_request = (File.open Rails.root.join( 
        'test/fixtures/wechat_post_menu_request')).read
      post :chat, menu_request, @parameters
      expect(response).to have_http_status(:ok)
      xml = Hash.from_xml(response.body).deep_symbolize_keys
      expect(xml).to eq({
          xml:
          {
            ToUserName: "123", 
            FromUserName: '404844425', 
            CreateTime: Time.now.to_i.to_s, 
            MsgType: 'text', 
            Content: I18n.t('chatreply.REQUIRE_SET_ADDRESS')
          }})
    end

    it "gets nothing because no caterings" do
      customer = omniauth_register_account
      menu_request = (File.open Rails.root.join( 
        'test/fixtures/wechat_post_menu_request')).read
      post :chat, menu_request, @parameters
      expect(response).to have_http_status(:ok)
      xml = Hash.from_xml(response.body).deep_symbolize_keys
      expect(xml).to eq({
          xml:
          {
            ToUserName: "123", 
            FromUserName: '404844425', 
            CreateTime: Time.now.to_i.to_s, 
            MsgType: 'text', 
            Content: I18n.t('chatreply.NO_CATERING_TODAY')
          }})
    end

    it 'get today menu' do
      customer = omniauth_register_account
      caterings = create_list :catering, 2, 
        building_id: customer.building_id
      menu_request = (File.open Rails.root.join( 
        'test/fixtures/wechat_post_menu_request')).read
      post :chat, menu_request, @parameters
      expect(response).to have_http_status(:ok)
      xml = Hash.from_xml(response.body).deep_symbolize_keys
      expect(xml).to eq({
          xml:
          {
            ToUserName: '123', 
            FromUserName: '404844425', 
            CreateTime: Time.now.to_i.to_s, 
            MsgType: 'news', 
            ArticleCount: '2',
            Articles: {
              item: 
                [{
                  Title: 'Shanghai Food',
                  Description: 'tariyaki chicken1',
                  PicUrl: 'http://combo_image',
                  Url: ''
                },
                {
                  Title: 'Shanghai Food',
                  Description: 'tariyaki chicken2',
                  PicUrl: 'http://combo_image',
                  Url: ''}]
            }}})
    end
  end
end
