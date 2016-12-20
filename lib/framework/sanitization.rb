module Sanitization
  TIME_INT_REGEX = /\d{8}/
  QUERY_REGEX = /([[:alnum:]])+([[:blank:]]|[[:alnum:]])*/
  QUANTITY_REGEX = /\A+?\d+\z/
  MAX_LIST_SIZE = 20

  SANITIZER = {
    time_int:   Proc.new { |time| 
      Sanitization.sanitize_time_int time },
    query:      Proc.new { |query| 
      Sanitization.sanitize_query query },
    file:       Proc.new { |file|
      Sanitization.sanitize_file file },
    quantity:   Proc.new { |quantity|
      Sanitization.sanitize_quantity quantity.to_s },
    dishes:      Proc.new { |list| 
      Sanitization.sanitize_list list },
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
    dish_order:     DishOrder,
    combo_order:    ComboOrder,
    dish:           Dish,
    dishes:         Dish,
    payment:        Payment,
    transaction:    Transaction,
    shipping:       Shipping,
  }

  def self.sanitize_time_int(time_int)
    if (time_int.to_s =~ TIME_INT_REGEX).nil?
      time_invalid = true
    else
      month = time_int / 1000000 
      day = (time_int / 10000) % 100
      hour = (time_int / 100) % 100
      min = time_int % 100
      leap = Date.leap? Time.now.year
      if [1, 3, 5, 7, 8, 10, 12].include? month
        time_invalid = day < 0 || day > 31
      elsif [4, 6, 9, 11].include? month
        time_invalid = day < 0 || day > 30
      elsif 2 == month
        time_invalid = day < 0 || (leap && day > 29) ||\
          (!leap && day > 28)
      else 
        time_invalid = true
      end
      time_invalid ||= (min % 15 != 0) || hour > 24 || hour < 0
    end
    raise Exceptions::BadParameter if time_invalid
    time_int
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
