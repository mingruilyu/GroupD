FactoryGirl.define do
  factory :restaurant do
   merchant
   category             
   city             
   location
   name             'Shanghai Food'
   image_url        'http://shanghai_food.com'
   certificate_url  'http://shanghai_food_certificate.com'
  end
end
