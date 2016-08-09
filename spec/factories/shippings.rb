FactoryGirl.define do
  factory :shipping do
    restaurant
    building

    status                Shipping::STATUS_WAITING
    price                 4.99
    estimated_arrival_at  4.hour.from_now
    available_until       2.hour.from_now
  end
end
