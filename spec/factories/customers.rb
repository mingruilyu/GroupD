FactoryGirl.define do
  factory :customer do
    building
    cellphone
    sequence(:email)        { |n| "david#{n}@dpool.com" }
    sequence(:uid)          { |n| "404844425#{n}" }
    username                'David'
    password                '12345678'
    password_confirmation   '12345678'
    type                    'Customer'
  end
end
