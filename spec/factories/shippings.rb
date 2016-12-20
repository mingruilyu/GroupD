FactoryGirl.define do
  factory :shipping do
    trait :default do
      building
      location
      restaurant_id         { 
                            restaurant = Restaurant.first 
                            if restaurant
                              restaurant.id
                            else
                              (create :restaurant, :unassociated).id
                            end
                          }
    end

    trait :unassociated do
      building_id         1
      location_id         1
      restaurant_id       1
    end

    estimated_arrival_at  10.hour.from_now
    status                Shipping::STATUS_WAITING
    
  end
end
