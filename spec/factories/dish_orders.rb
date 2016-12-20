FactoryGirl.define do
  factory :dish_order do
    trait :default do
      dish
      customer
      restaurant_id { self.dish.restaurant_id }
    end

    trait :unassociated do
      dish_id      1
      customer_id   1
      restaurant_id 1
    end

    shipping_id     { (create :shipping, :unassociated).id }
    quantity        1
    tax             1
    status          Order::STATUS_CHECKOUT
  end
end
