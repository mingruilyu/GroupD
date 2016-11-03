module Filter  

  def address_configuration
    raise Exceptions::AddressNotConfigured \
      if current_account.is_customer? &&\
        current_account.building_id.nil?
  end

  def cellphone_configuration
    raise Exceptions::CellphoneNotConfigured \
      if current_account.cellphone_id.nil?
  end

  def sanitize(action, targets={})
    unless action.is_a? Array
      action = [action]
    end
    return unless action.include? params[:action].to_sym

    targets.each do |name, type| 
      param = params.require name
      preprocessor = Sanitization::SANITIZER[type]
      param = preprocessor.nil? ? param : (preprocessor.call param)
      resource = Sanitization::RESOURCE_MAPPER[type]
      var = resource.nil? ? param : (resource.find param) 
      var_name = (name.to_s.end_with? 'id') ? type.to_s : name.to_s
      self.instance_variable_set("@#{var_name}", var)
    end
  end

  def authorize(action)
    unless action.is_a? Array
      action = [action]
    end
    return unless action.include? params[:action].to_sym

    targets = yield 
    unless targets.is_a? Array
      targets = [targets]
    end
    targets.each do |target|
      raise Exceptions::NotAuthorized unless target
    end
  end
end

module Sanitization

  TIME_INT_REGEX = /[[:digit:]]{4}*/
  QUERY_REGEX = /([[:alnum:]])+([[:blank:]]|[[:alnum:]])*/
  MAX_LIST_SIZE = 20

  SANITIZER = {
    date_int:   Proc.new { |date| 
      Sanitization.sanitize_date_int date },
    time_int:   Proc.new { |time| 
      Sanitization.sanitize_time_int time },
    query:      Proc.new { |query| 
      Sanitization.sanitize_query query },
    file:       Proc.new { |file|
      Sanitization.sanitize_file file },
    dishes:      Proc.new { |list| 
      Sanitization.sanitize_list list, Combo::MAX_DISH_COUNT },
    buildings:  Proc.new { |list|
      Sanitization.sanitize_list list },
  }

  RESOURCE_MAPPER = {
    account:        Account,
    merchant:       Merchant,
    customer:       Customer,
    combo:          Combo,
    company:        Company,
    building:       Building,
    buildings:      Building,
    catering:       Catering,
    cellphone:      Cellphone,
    restaurant:     Restaurant,
    category:       Category,
    city:           City,
    order:          Order,
    order_item:     OrderItem,
    dish:           Dish,
    dishes:         Dish,
    payment:        Payment,
  }

  def self.sanitize_time_int(time_int)
    raise Exceptions::BadParameter \
      if (time_int.to_s =~ TIME_INT_REGEX).nil? || time_int >= 2400 \
        || time_int <= 0 || ((time_int % 100) % 15 != 0)
    time_int
  end

  def self.sanitize_date_int(date_int)
    raise Exceptions::BadParameter \
      if (date_int.to_s =~ TIME_INT_REGEX).nil?
    month = date_int / 100
    day = date_int % 100
    leap = Date.leap? Time.now.year
    if [1, 3, 5, 7, 8, 10, 12].include? month
      date_invalid = day < 0 || day > 31
    elsif [4, 6, 9, 11].include? month
      date_invalid = day < 0 || day > 30
    elsif 2 == month
      date_invalid = day < 0 || (leap && day > 29) ||\
        (!leap && day > 28)
    else
      date_invalid = true
    end
    raise Exceptions::BadParameter if date_invalid
    date_int
  end

  def self.sanitize_query(query)
    raise Exceptions::BadParameter unless query =~ QUERY_REGEX
    ".*(#{query.split.join('|')}).*"
  end

  def self.sanitize_file(file)
    raise Exceptions::FileOversize \
      if file.size > UploadFile::MAX_FILE_SIZE 
    file
  end

  def self.sanitize_list(list, limit=MAX_LIST_SIZE)
    raise Exceptions::BadParameter if list.length > limit
    list
  end
end
