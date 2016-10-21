class Company < ActiveRecord::Base

  has_many :buildings

  scope :by_city, ->(city) { joins(:buildings).merge(
    Building.where(city_id: city)).distinct }

  scope :fuzzy_by_name, ->(name) { where('name REGEXP ?', name) }

  def as_json(options={})
    super only: :name
  end
end
