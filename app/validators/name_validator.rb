class NameValidator < ActiveModel::EachValidator
  MAX_NAME_LENGTH = 100
  def validate_each(record, attribute, value)
    unless (value.length <= MAX_NAME_LENGTH && value =~ \
      /\A([[:alpha:]]+)[[:blank:]]*([[[:alnum:]]_]*)$/)
      record.errors[attribute] = I18n.t 'error.INVALID_NAME'
    end
  end
end
