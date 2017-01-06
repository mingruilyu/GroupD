FactoryGirl.define do
  factory :cellphone do
    sequence(:number)  { |n| "805895536#{n}" }
  end
end
