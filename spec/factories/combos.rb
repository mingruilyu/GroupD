FactoryGirl.define do
  factory :combo do    
    price       10
    dishes      { [(create :dish).id] }
    restaurant_id { 
      restaurant = Restaurant.first
      if restaurant
        restaurant.id
      else
        (create :restaurant).id
      end
    }
    image_url   "http://combo_image"
  end
end
