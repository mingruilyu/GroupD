module Exceptions
  class ApplicationException < StandardError
    attr_accessor :message
    attr_accessor :status
    def initialize(message=nil, level=:error, status=nil)
      @message = message
      @status = status
      @level = level
    end

    def as_json
      return Response::JsonResponse.new(nil, @level => self.message)
    end
  end
  class NotAuthorized < ApplicationException
  end

  class AddressNotConfigured < ApplicationException
  end

  class NotEffective < ApplicationException
  end

  class BadParameter < ApplicationException
  end

  class BadRequest < ApplicationException
  end

  class StaleRecord < ApplicationException
  end

  class InvalidSetting < ApplicationException
  end
end
