FactoryGirl.define do
  factory :dish do
    restaurant
    name        'tariyaki chicken'
    price       10.0
    image_url   'http://dish/image.jpg'       
    desc        'example dish'
  end
end
