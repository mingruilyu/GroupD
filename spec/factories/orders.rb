FactoryGirl.define do
  factory :order do
    trait :default do
      food
      customer
      restaurant_id { self.food.restaurant_id }
      shipping_id   { shipping = Shipping.all.first 
                      if shipping.nil?
                        shipping = create :shipping, :unassociated,
                          estimated_arrival_at: (self.food.min_prepare_time + 1).hour.from_now
                      end
                      shipping.id}
    end

    trait :unassociated do
      food_id       1
      customer_id   1
      restaurant_id 1
      shipping_id   1
    end

    quantity        1
    tax             1
    status          Order::STATUS_CHECKOUT
  end
end
