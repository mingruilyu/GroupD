class Building < ActiveRecord::Base
  belongs_to :location
  belongs_to :company
  belongs_to :city
  
  def city_company_name
    "#{city.name}-#{company.name}-#{name}"
  end
end
