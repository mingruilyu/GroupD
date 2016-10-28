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
end
