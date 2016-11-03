module Operations
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

  class RequestMenu
    def initialize(account)
      @current_account = account
    end
    def execute
      if @current_account.building_id.nil?
        return result = {
          op_code: :request_menu,
          error: :address_not_set
        }
      end
      caterings = Catering.get_recent_menu_by_building(
        @current_account.building_id)
      objects = []
      caterings.each do |catering|
        objects.append({
          title: catering.restaurant.name,
          description: catering.combo.describe,
          pic_url: catering.combo.image_url,
        })
      end
      if objects.empty?
        result = {
          op_code: :request_menu,
          error: :no_catering
        }      
      else
        result = {
          op_code: :request_menu,
          objects: objects
        }
      end
    end
  end
end
