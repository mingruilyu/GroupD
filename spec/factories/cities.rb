FactoryGirl.define do
  factory :city do
    id              1
    initialize_with { 
      City.find_by_id(1) || City.create(name: 'San Jose') }
  end
end
