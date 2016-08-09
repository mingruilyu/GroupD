FactoryGirl.define do
  factory :cellphone do

    sequence(:number, 10)  { |n| "80589553#{n}" }

    trait :confirmation_sent do
      confirmation_token  '123456'
    end

    trait :confirmed do
      confirmed_at       { Time.now }
    end
  end
end
