FactoryGirl.define do
  factory :dish do
    restaurant_id 1
    sequence(:name) { |n| "tariyaki chicken#{n}" }
    price         10.0
    image_url     'http://dish/image.jpg'       
    desc          'example dish'
  end
end
