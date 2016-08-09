FactoryGirl.define do
  factory :customer do
    cellphone
    sequence(:email)        { |n| "david#{n}@dpool.com" }
    username                'David'
    password                '12345678'
    password_confirmation   '12345678'
    type                    'Customer'
  end
end
