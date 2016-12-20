FactoryGirl.define do
  factory :combo do    
    price       10
    dishes      { [(create :dish).id] }
    restaurant_id { 
      restaurant = Restaurant.first
      if restaurant
        restaurant.id
      else
        (create :restaurant, :unassociated).id
      end
    }
    image_url   "http://combo_image"
    available_until 2.hour.from_now
  end
end
