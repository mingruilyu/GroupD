FactoryGirl.define do
  factory :cart do
    sequence(:shipping_id) { |n| n }
    status   false
  end
end
