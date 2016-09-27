FactoryGirl.define do
  factory :combo do    
    price       10
    restaurant_id { 
      restaurant = Restaurant.first
      if restaurant
        restaurant.id
      else
        1
      end
    }
  end
end
