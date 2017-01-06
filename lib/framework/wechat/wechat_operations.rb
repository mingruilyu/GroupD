module WechatOperations
  module Filterable
    extend ActiveSupport::Concern

    included do
      include ActiveSupport::Callbacks
      include Filter
      define_callbacks :filters
    end

    module ClassMethods
      def before_execute(*filters)
        filters.each do |filter|
          self.set_callback :filters, :before, filter
        end
      end
    end

    def execute(session, account)
      run_callbacks :filters do
        self.do session, account
      end
    end

    def current_account
      @account
    end
  end

  class OmniauthRegisterAccount
    def initialize(uid, provider, type)
      @uid = uid
      @provider = provider
      @type = type
    end

    def execute(session, account)
      Account.omniauth_register type: @type, uid: @uid, 
        provider: @provider 
      result = {
        op_code: :omniauth_register_account
      }
    end
  end

  class ReportLocation
    def initialize(account, latitude, longitude, precision)
      @current_account = account
      @latitude = latitude
      @longitude = longitude
      @precision = precision
    end

    def execute
      result = { op_code: :report_location }
      if @current_account.building_id.nil?
        buildings = Building.by_coordinate @latitude, @longitude, 
          @precision
        if buildings.size == 1
          building = buildings.first
          @current_account.update_attribute :building_id, building.id
          result[:location] = building.describe
        elsif buildings.size > 1
          descriptions = []
          buildings.each do |building|
            descriptions.append building.describe
          end
          result[:locations] = descriptions
        end
      else
        result[:located] = @current_account.building.describe
      end
      result
    end
  end

  class RequestMenu
    include Filterable
    before_execute :registration
    before_execute :address_configuration
    #before_execute :cellphone_configuration

    def initialize(building_id)
      @building_id = building_id
    end

    def do(session, account)
      shippings = Shipping.active_by_building @building_id
      session.expect_msg_type = :text
      if shippings.size == 0
        result = nil
        session.next_op = nil
      elsif shippings.size == 1
        shipping = shippings.first
        restaurant_id = shipping.restaurant_id
        result, selector = list_food restaurant_id, shipping 
        session.next_state = :execute
        session.next_op = PlaceOrder.new
        session.selector = selector
      else
        result = { restaurant: [] }
        selector = {}
        shippings.each do |shipping|
          result[:restaurant] = shipping.restaurant
          selector[(index + 1).to_s] shipping.id
        end
        session.next_op = self
        session.next_state = :resume
        session.selector = selector
      end
      result
    end

    def resume(session, account, arg)
      shipping = Shipping.find arg
      result, selector = list_food shipping
      session.expect_msg_type = :text
      session.next_state = :execute
      session.next_op = PlaceOrder.new session, account
      session.selector = selector
      result
    end

    def self.assembly_reply(reply, result)
      if result.nil?
        reply[:MsgType] = 'text'
        reply[:Content] = I18n.t 'chatreply.NO_CATERING_TODAY'
        WechatMessage::Text.new reply
      else if result[:menu].present?
        reply[:MsgType] = 'news'
        articles = []
        result[:menu].each do |object|
          articles.append object.as_wechat_news
        end
        WechatMessage::NewsGroup.new reply, articles
      else
        reply[:MsgType] = 'text'
        text = ''
        result[:restaurant].each_with_index do |restaurant, index|
          text << (index + 1).to_s << ':' << restaurant.name << "\n"
        end
        reply[:Content] = text
        WechatMessage::Text.new reply
      end
    end

    private
      
      def list_food(shipping)
        result = {}
        selector = {}
        foods = Food.active_by_restaurant shipping.restaurant_id,
          shipping.estimated_arrival_at
        foods.each_with_index do |food, index|
          result[:menu].append food
          selector[(index + 1).to_s] = food.id
        end
        return result, selector
      end
  end

  class PlaceOrder
    include Filterable
    before_execute :registration
    before_execute :address_configuration
    #before_execute :cellphone_configuration

    def do(session, account)
      # TODO we may later need to check the user's overall order
      # quantity in one day.

      # since the customer only provide the menu index, we have to 
      # make sure the catering order here is the same as customer see.
      # TODO use in-memory cache to cache the menu list.
      caterings = Catering.get_recent_menu_by_building(
        @account.building_id)
      if @index < 0 || @index >= caterings.length
        raise Exceptions::InvalidCateringIndex
      end
      catering = caterings[@index]

      current_order = Order.active_order! @current_account.id
      item = current_order.add_item @quantity, nil, catering

      current_order.checkout! Payment::RECORD_CASH_ID

      result = { 
        op_code: :place_order, 
        restaurant: catering.restaurant.name,
        quantity: item.quantity, 
        combo: catering.combo.describe,
        total_price: current_order.total_price
      }
    end
  end

  class CancelOrder
    def initialize(account)
      @current_account = account
    end

    def execute
      result = { op_code: :cancel }
      orders = Order.checked_out @current_account.id
      if orders.size == 1
        order = orders.first
        order.cancel
        result[:item] = order.order_items.first
      elsif orders.size > 1
        items = []
        count = 1
        orders.each do |order|
          items.append "#{count}: #{order.order_items.first.describe}"
        end
        result[:items] = items
      end
      result
    end
  end

  class CheckStatus
    def initialize(account)
      @current_account = account
    end

    def execute
      orders = Order.checked_out @current_account.id
      status = []
      orders.each do |order|
        status.append({
          shipping_status: order.shipping.status,
          eta: order.shipping.catering.estimated_arrival_at,
          restaurant: order.shipping.catering.restaurant.name
        })
      end
      result = {
        op_code: :check_status,
        status: status
      }
    end
  end

  class PickUp
    def initialize(account)
      @current_account = account
    end

    def execute
      orders = Order.fulfilled @current_account.id
      if orders.empty?
        result = { op_code: :pick_up }
      else
        uri = URI 'http://www.katering.com/customer/pick_up_code'
        params = @current_account.get_token_hash
        uri.query = URI.encode_www_form params
        result = {
          op_code: :pick_up,
          uri: uri.to_s
        }
      end
    end
  end

  class Delegate
    include Filterable
    before_execute :address_configuration
    #before_execute :cellphone_configuration

    def initialize(account)
      @current_account = account
    end

    def execute
      uri = URI 'http://www.katering.com/customer/delegate'
      params = @current_account.get_token_hash
      uri.query = URI.encode_www_form params
      result = {
        op_code: :delegate,
        uri: uri.to_s
      }
    end
  end

  class Noop
    def execute
      result = {
        op_code: :noop
      }
    end
  end
end
