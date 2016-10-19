class NumberValidator < ActiveModel::EachValidator
  US_CELLPHONE_NUMBER_LENGTH = 10 # without area code
  def validate_each(record, attribute, value)
    unless value =~ /[[:digit:]]{#{US_CELLPHONE_NUMBER_LENGTH}}/
      record.errors[attribute] << I18n.t('error.INVALID_NUMBER') 
    end
  end
end
