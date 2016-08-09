FactoryGirl.define do
  factory :order do
    shipping
    cart
    payment
  end
end
