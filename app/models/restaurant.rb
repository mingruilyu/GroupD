class Restaurant < ActiveRecord::Base

  belongs_to :merchant
  belongs_to :category
  belongs_to :location 
  belongs_to :city
  has_many :dishes
  has_many :combos

  STATUS_OPEN = 0
  STATUS_CLOSED = 1

  validates :name, uniqueness: true
  validates :image_url, :name, presence: true

  scope :open_by_merchant, ->(merchant) { 
    where(merchant_id: merchant, status: STATUS_OPEN) }

  def self.name_valid?(name)
    Restaurant.find_by_name(name).nil?
  end

  def self.create_restaurant(merchant_id, name, location, image_url, category, 
    city)
    Restaurant.create! merchant_id: merchant_id, name: name, 
      location_id: location, image_url: image_url, 
      category_id: category.id, city_id: city.id
  end

  def update name, location_id, image_url
    self.update_attributes name: name, location_id: location_id, 
      image_url: image_url
  end

  def close
    Restaurant.transaction do
      self.lock!
      self.update_attribute :status, STATUS_CLOSED
    end
  end

  def as_json(options={})
    super only: [:name, :image_url, :category_id, :location_id]
  end
end
