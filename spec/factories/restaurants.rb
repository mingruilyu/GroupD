FactoryGirl.define do
  factory :restaurant do
    trait :default do
      merchant_id  { merchant = (Merchant.find_or_create_by id: 1)
                     merchant.id }
      category             
      city             
    end

    trait :unassociated do
      merchant_id   1
      category_id   1
      city_id       1
    end

    location
    sequence(:name)  { |n| "Shanghai Food#{n}" }
    image_url        'http://shanghai_food.com'
    certificate_url  'http://shanghai_food_certificate.com'
  end
end
