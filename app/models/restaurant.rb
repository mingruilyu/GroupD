class Restaurant < ActiveRecord::Base

  belongs_to :merchant
  belongs_to :category
  belongs_to :location 
  belongs_to :city
  has_many :dishes
  has_many :combos

  STATUS_OPEN = 0
  STATUS_CLOSED = 1

  validates :name, presence: true, uniqueness: true, name: true
  validates :image_url, presence: true, url: true

  scope :open_by_merchant, ->(merchant) { 
    where(merchant_id: merchant, status: STATUS_OPEN) }

  def update! name, location_id, image_url
    self.update_attributes! name: name, location_id: location_id, 
      image_url: image_url
  end

  def close!
    Restaurant.transaction do
      self.lock!
      self.update_attribute :status, STATUS_CLOSED
    end
  end

  def as_json(options={})
    super only: [:name, :image_url, :category_id, :location_id]
  end

end
