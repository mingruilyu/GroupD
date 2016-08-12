FactoryGirl.define do
  factory :merchant do
    cellphone
    email                   'tom@dpool.com'
    username                'Tom'
    password                '12345678'
    password_confirmation   '12345678'
    type                    'Merchant'
  end
end