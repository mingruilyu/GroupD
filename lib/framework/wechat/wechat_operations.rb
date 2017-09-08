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

    def execute(args)
      run_callbacks :filters do
        self.do args
      end
    end

    def current_account
      @account
    end
  end

  class Operation
    def self.assembly_reply(sender, receiver, result)
      hash = {
        FromUserName: sender,
        ToUserName:   receiver,
        CreateTime:   Time.now.to_i
      }
      if result[:error].present?
        hash[:MsgType] = 'text'
        hash[:Content] = I18n.t 'chatreply.OPERATION_ERROR'
        reply = WechatMessage::Text.new hash
      else
        reply = yield hash
      end
      reply
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

  class RequestMenu < Operation
    include Filterable
    before_execute :registration
    before_execute :address_configuration
    #before_execute :cellphone_configuration

    def initialize(building_id)
      @building_id = building_id
    end

    def do(args)
      shippings = Shipping.active_by_building @building_id
      session.expect_msg_type = :text
      if shippings.size == 0
        result = nil
        session.next_op = nil
      else
        result = {}
        selector = {}
        index = 0
        shippings.each do |shipping|
          menu = []
          foods = Food.active_by_restaurant shipping.restaurant_id,
            shipping.estimated_arrival_at
          foods.each do |food|
            menu.append food
            selector[(index + 1).to_s] food.id
          end
          result[shipping.restaurant.name] = menu
        end
        session.next_op = ShowDetails.new
        session.selector = selector
      end
      result
    end

    def self.assembly_reply(sender, receiver, result)
      super sender, receiver, result do |reply|
      if result.nil?
        reply[:MsgType] = 'text'
        reply[:Content] = I18n.t 'chatreply.NO_CATERING_TODAY'
        WechatMessage::Text.new reply
      else
        reply[:MsgType] = 'text'
        text = ''
        index = 1
        result.each do |restaurant_name, menu|
          text << "#{restaurant_name}:\n"
          menu.each_with do |food|
            text << "\t#{index: food.name}\n"
            index += 1
          end
        end
        reply[:Content] = text
        WechatMessage::Text.new reply
      end
    end
  end

  class ShowDetails
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
