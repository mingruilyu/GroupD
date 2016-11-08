module Sanitization
  TIME_INT_REGEX = /[[:digit:]]{4}*/
  QUERY_REGEX = /([[:alnum:]])+([[:blank:]]|[[:alnum:]])*/
  QUANTITY_REGEX = /\A+?\d+\z/
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
    quantity:   Proc.new { |quantity|
      Sanitization.sanitize_quantity quantity.to_s },
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
    transaction:    Transaction,
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

  def self.sanitize_quantity(quantity)
    raise Exceptions::BadParameter unless quantity =~ QUANTITY_REGEX
    quantity.to_i
  end

  def self.sanitize_list(list, limit=MAX_LIST_SIZE)
    raise Exceptions::BadParameter if list.length > limit
    list
  end

  def self.sanitize_params(params, optional, mandatory)
    result = {}
    targets = optional.merge mandatory
    targets.each do |name, type| 
      if mandatory.has_key? name
        param = params.require name
      else
        param = params[name]
      end
      preprocessor = Sanitization::SANITIZER[type]
      param = preprocessor.nil? ? param : (preprocessor.call param)
      resource = Sanitization::RESOURCE_MAPPER[type]
      var = resource.nil? ? param : (resource.find param) 
      var_name = (name.to_s.end_with? 'id') ? type.to_s : name.to_s
      result[var_name] = var 
    end
    result
  end

  def self.validate_authorization
    targets = yield 
    unless targets.is_a? Array
      targets = [targets]
    end
    targets.each do |target|
      raise Exceptions::NotAuthorized unless target
    end
  end
end
