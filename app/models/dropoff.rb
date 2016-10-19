class Dropoff < ActiveRecord::Base
  belongs_to :building

  scope :by_merchant, ->(merchant) { where(merchant_id: merchant) }
  scope :by_building, ->(building) { where(building_id: building) }

  def sanitize(id)
  end

  def as_json(options={})
    super only: :building_id
  end
end
