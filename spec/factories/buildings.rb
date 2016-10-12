FactoryGirl.define do
  factory :building do
    company
    location
    city
    sequence(:name)          { |n| "Building#{n}" }
  end
end
