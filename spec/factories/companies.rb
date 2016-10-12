FactoryGirl.define do
  factory :company do
    sequence(:name)     { |n| "oracle#{n}" }
  end
end
