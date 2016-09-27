module Exceptions
  class NotAuthorized < StandardError
  end

  class AddressNotConfigured < StandardError
  end

  class OrderEmpty < StandardError
  end

  class OrderStatusError < StandardError
  end

  class CateringExpired < StandardError
  end
end
