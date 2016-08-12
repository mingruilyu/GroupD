FactoryGirl.define do
  factory :cart_item do
    trait :combo_item do
      catering
    end

    trait :dish_item do
      dish
    end
  end
end
