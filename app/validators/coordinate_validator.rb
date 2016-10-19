class CoordinateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << Message::Error::INVALID_COORDINATE \
      unless Float(value) rescue false
  end
end
