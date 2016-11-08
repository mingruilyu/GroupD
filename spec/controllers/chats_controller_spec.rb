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

  context 'Not Registered' do
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
          Content: I18n.t('chatreply.REPLY_WELCOME')
        }})
    end
  end

  context 'Registered' do
    before :each do
      @customer = omniauth_register_account
    end

    describe 'GET MENU' do
      it 'gets nothing because address not set' do
        @customer.update_attribute :building_id, nil
        menu_request = generate_wechat_text_message 'menu'
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
            Content: I18n.t('error.ADDRESS_NOT_CONFIGURED')
          }})
      end

      it "gets nothing because no caterings" do
        menu_request = generate_wechat_text_message 'menu'
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

      it 'gets today menu' do
        caterings = create_list :catering, 2, 
          building_id: @customer.building_id
        menu_request = generate_wechat_text_message 'menu'
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

    describe 'ORDER' do
      it 'fails because building not set' do
        @customer.update_attribute :building_id, nil
        order_request = generate_wechat_text_message '1+1'
        post :chat, order_request, @parameters
        expect(response).to have_http_status(:ok)
        xml = Hash.from_xml(response.body).deep_symbolize_keys
        expect(xml).to eq({
          xml:
          {
            ToUserName: "123", 
            FromUserName: '404844425', 
            CreateTime: Time.now.to_i.to_s, 
            MsgType: 'text', 
            Content: I18n.t('error.ADDRESS_NOT_CONFIGURED')
          }})
      end

      it 'fails because index invalid' do
        order_request = generate_wechat_text_message '1+1'
        post :chat, order_request, @parameters
        expect(response).to have_http_status(:ok)
        xml = Hash.from_xml(response.body).deep_symbolize_keys
        expect(xml).to eq({
          xml:
          {
            ToUserName: "123", 
            FromUserName: '404844425', 
            CreateTime: Time.now.to_i.to_s, 
            MsgType: 'text', 
            Content: I18n.t('error.INVALID_CATERING_INDEX')
          }})
      end

      it 'orders the catering' do
        create_list :catering, 2, 
          building_id: @customer.building_id
        caterings = Catering.get_recent_menu_by_building(
          @customer.building_id)
        order_request = generate_wechat_text_message '1+10'
        post :chat, order_request, @parameters
        expect(response).to have_http_status(:ok)
        xml = Hash.from_xml(response.body).deep_symbolize_keys
        expect(xml).to eq({
          xml:
          {
            ToUserName: "123", 
            FromUserName: '404844425', 
            CreateTime: Time.now.to_i.to_s, 
            MsgType: 'text', 
            Content: I18n.t('chatreply.PLACE_ORDER', quantity: 10, 
              combo: caterings[0].combo.describe, 
              restaurant: caterings[0].restaurant.name)}})
      end

      it 'fails because quantity over limit' do
        create_list :catering, 2, 
          building_id: @customer.building_id
        order_request = generate_wechat_text_message '1+11'
        post :chat, order_request, @parameters
        expect(response).to have_http_status(:ok)
        xml = Hash.from_xml(response.body).deep_symbolize_keys
        expect(xml).to eq({
          xml:
          {
            ToUserName: "123", 
            FromUserName: '404844425', 
            CreateTime: Time.now.to_i.to_s, 
            MsgType: 'text', 
            Content: I18n.t('error.ORDER_INVALID_QUANTITY')
          }})
      end
    end
  end
end
