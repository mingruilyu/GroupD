FactoryGirl.define do
  factory :combo_order do
    trait :default do
      combo
      customer
      restaurant_id { self.combo.restaurant_id }
    end

    trait :unassociated do
      combo_id      1
      customer_id   1
      restaurant_id 1
    end

    shipping_id     { (create :shipping, :unassociated).id }
    quantity        1
    tax             1
    status          Order::STATUS_CHECKOUT
  end
end
