FactoryGirl.define do
  factory :debt do
    loaner_id       {
      merchant = Merchant.first || create(:merchant)
      merchant.id
    }
    customer
    sequence(:debtor_id) { |n| n }       
    amount          10
  end
end
