require 'rails_helper'

RSpec.describe ChatsController, type: :controller do
  before :each do
    @parameters = YAML.load File.open(
      Rails.root.join 'test/fixtures/wechat_post_params.yml') 
    @parameters['format'] = :xml
    @bot_id = Services::WechatBot.bot_id
  end

  describe 'parameter validation' do
    it 'fails because signature does not match'  do
      @parameters['nonce'] = '123456789'
      post :chat, 'nothing there', @parameters
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'Not Registered' do
    it 'checks the configuration' do
      @parameters['echostr'] = '123456789'
      get :configuration, @parameters
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq('123456789')
    end

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
          FromUserName: @bot_id, 
          CreateTime: Time.now.to_i.to_s, 
          MsgType: 'text', 
          Content: I18n.t('chatreply.REPLY_WELCOME')
        }})
    end

    it 'fails because not registered' do
      menu_request = generate_wechat_text_message 'menu'
      post :chat, menu_request, @parameters
      expect(response).to have_http_status(:ok)
      xml = Hash.from_xml(response.body).deep_symbolize_keys
      expect(xml).to eq({
        xml:
        {
          ToUserName: "123", 
          FromUserName: @bot_id, 
          CreateTime: Time.now.to_i.to_s, 
          MsgType: 'text', 
          Content: I18n.t('error.NOT_AUTHORIZED')
        }})
    end
  end

  context 'Registered' do
    before :each do
      @customer = omniauth_register_account
    end

    describe 'NOT RECOGNIZED' do
      it 'replies with not recognized' do
        random = generate_wechat_text_message 'unknown'
        post :chat, random, @parameters
        expect(response).to have_http_status(:ok)
        xml = Hash.from_xml(response.body).deep_symbolize_keys
        expect(xml).to eq({
          xml:
          {
            ToUserName: "123", 
            FromUserName: Services::WechatBot.bot_id, 
            CreateTime: Time.now.to_i.to_s, 
            MsgType: 'text', 
            Content: I18n.t('chatreply.INSTRUCTION_NOT_RECOGNIZED')
          }})
      end
    end

    describe 'REPORT LOCATION' do
      before :each do
        @report_location = (File.open Rails.root.join( 
          'test/fixtures/wechat_post_location')).read
      end
      it 'reports location not found' do
        @customer.update_attribute :building_id, nil
        post :chat, @report_location, @parameters
        expect(response).to have_http_status(:ok)
        xml = Hash.from_xml(response.body).deep_symbolize_keys
        expect(xml).to eq({
          xml:
          {
            ToUserName: "123", 
            FromUserName: Services::WechatBot.bot_id, 
            CreateTime: Time.now.to_i.to_s, 
            MsgType: 'text', 
            Content: I18n.t('chatreply.NO_LOCATION_FOUND')
          }})
      end

      it 'auto set location because only one found' do
        @customer.update_attribute :building_id, nil
        location = create :location, lat: 37.4, lng: -121.94
        building = create :building, location_id: location.id
        post :chat, @report_location, @parameters
        expect(response).to have_http_status(:ok)
        xml = Hash.from_xml(response.body).deep_symbolize_keys
        expect(xml).to eq({
          xml:
          {
            ToUserName: "123", 
            FromUserName: Services::WechatBot.bot_id, 
            CreateTime: Time.now.to_i.to_s, 
            MsgType: 'text', 
            Content: I18n.t('chatreply.AUTO_SET_LOCATION', 
              location: building.describe)
          }})
      end

      it 'reports multiple locations' do
        @customer.update_attribute :building_id, nil
        location_1 = create :location, lat: 37.4, lng: -121.94
        location_2 = create :location, lat: 37.5, lng: -121.84
        building_1 = create :building, location_id: location_1.id
        building_2 = create :building, location_id: location_2.id
        post :chat, @report_location, @parameters
        expect(response).to have_http_status(:ok)
        xml = Hash.from_xml(response.body).deep_symbolize_keys
        description = []
        description.append building_1.describe
        description.append building_2.describe
        expect(xml).to eq({
          xml:
          {
            ToUserName: "123", 
            FromUserName: Services::WechatBot.bot_id, 
            CreateTime: Time.now.to_i.to_s, 
            MsgType: 'text', 
            Content: I18n.t('chatreply.MULTIPLE_LOCATIONS', 
              locations: description.join("\n"))
          }})
      end
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
            FromUserName: @bot_id, 
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
            FromUserName: @bot_id, 
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
            FromUserName: @bot_id, 
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
            FromUserName: @bot_id, 
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
            FromUserName: @bot_id, 
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
            FromUserName: @bot_id, 
            CreateTime: Time.now.to_i.to_s, 
            MsgType: 'text', 
            Content: I18n.t('chatreply.PLACE_ORDER', quantity: 10, 
              combo: caterings[0].combo.describe, 
              restaurant: caterings[0].restaurant.name,
              price: caterings[0].combo.price * 10 * 1.1)}})
      end

      it 'fails because quantity over limit' do
        create_list :catering, 2, building_id: @customer.building_id
        order_request = generate_wechat_text_message '1+11'
        post :chat, order_request, @parameters
        expect(response).to have_http_status(:ok)
        xml = Hash.from_xml(response.body).deep_symbolize_keys
        expect(xml).to eq({
          xml:
          {
            ToUserName: "123", 
            FromUserName: @bot_id, 
            CreateTime: Time.now.to_i.to_s, 
            MsgType: 'text', 
            Content: I18n.t('error.ORDER_INVALID_QUANTITY')
          }})
      end
    end

    describe 'CHECK STATUS' do
      before :each do
        @status_check = generate_wechat_text_message 'status'
      end

      it 'gets no active order status' do
        post :chat, @status_check, @parameters
        expect(response).to have_http_status(:ok)
        xml = Hash.from_xml(response.body).deep_symbolize_keys
        expect(xml).to eq({
          xml:
          {
            ToUserName: "123", 
            FromUserName: @bot_id, 
            CreateTime: Time.now.to_i.to_s, 
            MsgType: 'text', 
            Content: I18n.t('chatreply.NO_ACTIVE_ORDER')
          }})
      end

      it 'gets order shipping status' do
        catering = create :catering,building_id: @customer.building_id
        orders = create_list :order, 2, customer_id: @customer.id
        orders.each do |order|
          order.add_item 1, nil, catering
          order.update_attribute :status, Order::STATUS_CHECKOUT
        end
        post :chat, @status_check, @parameters
        expect(response).to have_http_status(:ok)
        xml = Hash.from_xml(response.body).deep_symbolize_keys
        expect(xml).to eq({
          xml:
          {
            ToUserName: "123", 
            FromUserName: @bot_id, 
            CreateTime: Time.now.to_i.to_s, 
            MsgType: 'text', 
            Content: I18n.t('chatreply.ORDER_STATUS_TITLE', 
              restaurant: catering.restaurant.name) + \
              I18n.t('chatreply.SHIPPING_WAITING') + \
              I18n.t('chatreply.ESTIMATE_ARRIVAL_TIME', 
                time: catering.estimated_arrival_at) + "\n" + \
              I18n.t('chatreply.ORDER_STATUS_TITLE', 
                restaurant: catering.restaurant.name) + \
              I18n.t('chatreply.SHIPPING_WAITING') + \
              I18n.t('chatreply.ESTIMATE_ARRIVAL_TIME',
                time: catering.estimated_arrival_at)
          }})
      end
    end

    describe 'PICK UP' do
      before :each do
        @pickup = generate_wechat_text_message 'pickup'
      end

      it 'replies no active order' do
        post :chat, @pickup, @parameters
        expect(response).to have_http_status(:ok)
        xml = Hash.from_xml(response.body).deep_symbolize_keys
        expect(xml).to eq({
          xml:
          {
            ToUserName: "123", 
            FromUserName: @bot_id, 
            CreateTime: Time.now.to_i.to_s, 
            MsgType: 'text', 
            Content: I18n.t('chatreply.NO_ACTIVE_ORDER')
          }})
      end

      it 'sends a link' do
        catering = create :catering,
          building_id: @customer.building_id
        order = create :order, customer_id: @customer.id
        order.add_item 1, nil, catering
        order.update_attribute :status, Order::STATUS_FULFILLED
        post :chat, @pickup, @parameters
        expect(response).to have_http_status(:ok)
        xml = Hash.from_xml(response.body).deep_symbolize_keys
        expect(xml).to eq({
          xml:
          {
            ToUserName: "123", 
            FromUserName: @bot_id, 
            CreateTime: Time.now.to_i.to_s, 
            MsgType: 'text', 
            Content: "<a href=\"http://www.katering.com/customer/pick_up_code?client=#{@customer.tokens.keys.first}&uid=#{@customer.uid}&access-token\">#{I18n.t('chatreply.PICK_UP')}</a>" 
          }})
      end
    end
  end
end
