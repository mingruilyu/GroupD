class Building < ActiveRecord::Base
  belongs_to :location
  belongs_to :company
  belongs_to :city

  validates_associated :location, :company, :city
  
  scope :by_city_company, ->(city, company) { 
    where(company_id: company, city_id: city) } 

  scope :by_coordinate, ->(lat, lng, precision) {
    joins(:location).merge(Location.where(
      '(lat BETWEEN ? AND ?) AND (lng BETWEEN ? AND ?)', 
      lat - precision, lat + precision, lng - precision, 
      lng + precision)) }

  scope :by_address_name, ->(query) {
    query = ".*(#{query.split.join('|')}).*"
    joins(:location).where('address REGEXP ? OR name REGEXP ?', 
      query, query) }

  def describe
    self.city.name + ' ' + self.company.name + ' ' + self.name
  end

  def as_json(options={})
    super except: [:created_at, :updated_at]
  end
end
