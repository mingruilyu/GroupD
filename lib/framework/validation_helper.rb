module Validation
  def city_should_be_valid
    unless City.find(self.city_id)
      errors.add(:base, I18n.t('city.error.INVALID_CITY'))
    end
  end
end
