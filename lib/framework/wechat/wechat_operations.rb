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

    def execute
      run_callbacks :filters do
        self.do
      end
    end

    def current_account
      @current_account
    end
  end

  class OmniauthRegisterAccount
    def initialize(uid, provider, type)
      @uid = uid
      @provider = provider
      @type = type
    end

    def execute
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
    before_execute :cellphone_configuration

    def initialize(account)
      @current_account = account
    end

    def do
      caterings = Catering.get_recent_menu_by_building(
        @current_account.building_id)
      result = { 
        op_code: :request_menu, 
        caterings: caterings 
      }
    end
  end

  class PlaceOrder
    include Filterable
    before_execute :registration
    before_execute :address_configuration
    before_execute :cellphone_configuration

    def initialize(account, index, quantity)
      @current_account = account
      @index = index
      @quantity = quantity
    end

    def do
      # TODO we may later need to check the user's overall order
      # quantity in one day.

      # since the customer only provide the menu index, we have to 
      # make sure the catering order here is the same as customer see.
      # TODO use in-memory cache to cache the menu list.
      caterings = Catering.get_recent_menu_by_building(
        @current_account.building_id)
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
    before_execute :cellphone_configuration

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
