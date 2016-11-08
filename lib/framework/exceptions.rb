module Exceptions
  class ApplicationError < StandardError
  end

  class NotAuthorized < ApplicationError
    def message
      I18n.t 'error.NOT_AUTHORIZED'
    end
  end

  class FileOversize < ApplicationError
    def message
      I18n.t 'error.FILE_OVERSIZE'
    end
  end

  class BadParameter < ApplicationError
    def message
      I18n.t 'error.BAD_PARAMETER'
    end
  end

  class AddressNotConfigured < ApplicationError
    def message
      I18n.t 'error.ADDRESS_NOT_CONFIGURED'
    end
  end

  class CellphoneNotConfigured < ApplicationError
    def message
      I18n.t 'error.CELLPHONE_NOT_CONFIGURED'
    end
  end

  class InvalidCateringIndex < ApplicationError
    def message
      I18n.t 'error.INVALID_CATERING_INDEX'
    end
  end

  class NotEffective < ActiveRecord::RecordInvalid
  end
 
  class StaleRecord < ActiveRecord::RecordInvalid
  end

end
