class UrlValidator < ActiveModel::EachValidator
  MAX_URL_LENGTH = 255
  def validate_each(record, attribute, value)
    unless (value.length <= MAX_URL_LENGTH && \
      value =~ /\A(http:\/\/)(.*)$/)
      record.errors[attribute] = I18n.t 'error.INVALID_URL'
    end
  end
end
