module Filter  

  def registration
    raise Exceptions::NotAuthorized if current_account.nil?
  end

  def address_configuration
    raise Exceptions::AddressNotConfigured \
      if current_account.is_customer? &&\
        current_account.building_id.nil?
  end

  def cellphone_configuration
    raise Exceptions::CellphoneNotConfigured \
      if current_account.cellphone_id.nil?
  end
end
