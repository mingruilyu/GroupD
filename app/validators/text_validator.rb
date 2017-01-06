class TextValidator < ActiveModel::EachValidator
  MAX_TEXT_LENGTH = 250
  def validate_each(record, attribute, value)
    if value.present? && value.length > MAX_TEXT_LENGTH
      record.errors[attribute] << (I18n.t 'text.error.TEXT_TOO_LONG')
    end
  end
end
