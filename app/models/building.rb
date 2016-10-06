class Building < ActiveRecord::Base
  belongs_to :location
  belongs_to :company
  belongs_to :city

  validates_associated :location, :company, :city
  
  def city_company_name
    "#{city.name}-#{company.name}-#{name}"
  end

  def as_json(options={})
    super except: [:created_at, :updated_at]
  end
end
