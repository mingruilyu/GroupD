FactoryGirl.define do
  factory :order do
    cart_id         1
    transaction_id  1
    total_price     10
    customer_id     1
  end
end
