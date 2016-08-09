FactoryGirl.define do
  factory :category do
    id              1
    initialize_with { 
      Category.find_by_id(1) || Category.create(name: 'Chinese Food') }
  end
end
