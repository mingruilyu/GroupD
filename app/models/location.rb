class Location < ActiveRecord::Base

  validates :lng, :lat, coordinate: true

  BUILDING_COORDINATE_RESOLUTAION = 0.2

  def self.from_json(json)
    Location.new address: json['formatted_address'], 
      lat: json['geometry']['location']['lat'], 
      lng: json['geometry']['location']['lng']
  end

  def as_json(options={})
    hash = {
      'address': self.address,
      'lat': self.lat.as_json,
      'lng': self.lng.as_json
    }
  end
end
