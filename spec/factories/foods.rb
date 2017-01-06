FactoryGirl.define do
  factory :food do    
    price       10
    restaurant_id { 
      restaurant = Restaurant.first
      if restaurant
        restaurant.id
      else
        (create :restaurant, :unassociated).id
      end
    }
    sequence(:name)  { |n| "Tariyaki Chicken #{n}" }
    image_url   "http://combo_image"
    min_prepare_time 1
    quota       10
  end
end
