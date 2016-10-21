FactoryGirl.define do
  factory :cellphone do
    sequence(:number, 10)  { |n| "805895536#{n}" }
  end
end
