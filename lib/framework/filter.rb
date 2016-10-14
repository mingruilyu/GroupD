module Filter  

  def format_sanitization
    raise ActionController::UnknownFormat \
      unless request.format == :json
  end

  def address_configuration
    raise Exceptions::AddressNotConfigured \
      if current_account.is_customer? &&\
        current_account.building_id.nil?
  end

  def sanitize(action, targets={})
    unless action.is_a? Array
      action = [action]
    end
    return unless action.include? params[:action].to_sym

    targets.each do |name, type| 
      param = params.require name
      handler = Sanitization::DISPATCHER[type]
      var = handler.nil? ? param : (handler.call param)
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

  MAX_TEXT_LENGTH = 250
  MAX_NAME_LENGTH = 100
  MAX_URL_LENGTH = 255
  NAME_REGEX = /[[:alpha:]][\s[[:alnum:]]_]*/
  HTTP_REGEX = /http:\/\/.*/
  INT_REGEX = /[[:digit:]]*/
  QUERY_REGEX = /([[:alnum:]])+([[:blank:]]|[[:alnum:]])*/

  DISPATCHER = {
    customer:   Proc.new { |id| Customer.find id },
    merchant:   Proc.new { |id| Merchant.find id },
    combo:      Proc.new { |id| Combo.find id },
    company:    Proc.new { |id| Company.find id },
    building:   Proc.new { |id| Building.find id },
    buildings:  Proc.new { |ids| 
      buildings = [] 
      ids.each do |id|
        buildings.append(Building.find id)
      end
      buildings
    },
    catering:   Proc.new { |id| Catering.find id },
    category:   Proc.new { |id| Category.find id },
    city:       Proc.new { |id| City.find id },
    restaurant: Proc.new { |id| Restaurant.find id },
    order:      Proc.new { |id| Order.find id },
    order_item: Proc.new { |id| OrderItem.find id },
    dish:       Proc.new { |id| Dish.find id },
    dishes:     Proc.new { |ids| 
      dishes = []
      raise Exceptions::BadParameter \
        if ids.length > Combo::MAX_DISH_COUNT
      ids.each do |id|
        dishes.append(Dish.find id)
      end
      dishes
    },
    payment:    Proc.new { |id| id.to_i == Payment::RECORD_CASH_ID ? \
      Payment.record_cash : (Payment.find id) },
    date_int:   Proc.new { |date| 
      Sanitization.sanitize_date_int date },
    time_int:   Proc.new { |time| 
      Sanitization.sanitize_time_int time },
    name:       Proc.new { |name| 
      Sanitization.sanitize_name(name.strip) },
    text:       Proc.new { |text| 
      Sanitization.sanitize_text(text.strip) },
    url:        Proc.new { |url|
      Sanitization.sanitize_url(url.strip) },
    coord:      Proc.new { |coordinate| 
      Sanitization.sanitize_coordinate coordinate },
    query:      Proc.new { |query| 
      Sanitization.sanitize_query query },
    file:       Proc.new { |file|
      Sanitization.sanitize_file file },
  }

  def self.sanitize_time_int(time_int)
    raise Exceptions::BadParameter \
      if (time_int.to_s =~ INT_REGEX).nil? || time_int >= 2400 \
        || time_int <= 0 || ((time_int % 100) % 15 != 0)
    time_int
  end

  def self.sanitize_date_int(date_int)
    raise Exceptions::BadParameter \
      if (date_int.to_s =~ INT_REGEX).nil?
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

  def self.sanitize_name(name)
    raise Exceptions::BadParameter if name.length > MAX_NAME_LENGTH \
      || (name =~ NAME_REGEX).nil?
    name
  end

  def self.sanitize_url(url)
    raise Exceptions::BadParameter if url.length > MAX_URL_LENGTH \
      || (url =~ HTTP_REGEX).nil?
    url
  end

  def self.sanitize_text(text)
    raise Exceptions::BadParameter if text.length > MAX_TEXT_LENGTH 
    text
  end

  def self.sanitize_coordinate(coord)
    raise Exceptions::BadParameter unless Float(coord) rescue false
    coord.to_f
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
end
