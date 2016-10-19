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

  class NotEffective < ActiveRecord::RecordInvalid
  end
 
  class StaleRecord < ActiveRecord::RecordInvalid
  end

end
