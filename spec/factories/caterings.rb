FactoryGirl.define do
  factory :catering do
    combo
    shipping
    available_until 1.hour.from_now
    restaurant_id { self.combo.restaurant_id }
  end
end
