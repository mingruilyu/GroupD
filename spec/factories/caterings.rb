FactoryGirl.define do
  factory :catering do
    combo 
    shipping
    building
    available_until 2.hour.from_now
    estimated_arrival_at 3.hour.from_now
    restaurant_id { self.combo.restaurant_id }
  end
end
