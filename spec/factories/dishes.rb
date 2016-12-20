FactoryGirl.define do
  factory :dish do
    restaurant_id {
      restaurant = Restaurant.first
      if restaurant
        restaurant.id
      else
        (create :restaurant, :unassociated).id
      end
    }
    sequence(:name) { |n| "tariyaki chicken#{n}" }
    price             10.0
    image_url         'http://dish/image.jpg'       
    desc              'example dish'
    min_prepare_time  2
  end
end
