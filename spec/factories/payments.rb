FactoryGirl.define do
  factory :payment do
    customer
    payment_type      0
    add_attribute(:method) { '123456789' }
  end
end
