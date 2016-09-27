module Filter  
  def request_format_filter
    raise ActionController::UnknownFormat \
      unless request.format == :json
  end

  def address_configuration_filter
    raise Exceptions::AddressNotConfigured \
      if controller.current_account.is_customer? &&\
        controller.current_account.building_id.nil?
  end

  def merchant_authorization_filter
    raise Exceptions::NotAuthorized \
      if params[:merchant_id].to_i != current_account.id
  end

  def customer_authorization_filter
    raise Exceptions::NotAuthorized \
      if params[:customer_id].to_i != current_account.id
  end
end
