FactoryGirl.define do
  factory :merchant do
    cellphone
    sequence(:email)        { |n| "tom#{n}@dpool.com" }
    sequence(:uid)          { |n| "40484426#{n}" }
    username                'Tom'
    password                '12345678'
    password_confirmation   '12345678'
    type                    'Merchant'
    provider                'email'
  end
end
