FactoryGirl.define do
  factory :transaction do
    sender_id         {
      customer = Customer.first || create(:customer)
      customer.id
    }
    receiver_id       {
      merchant = Merchant.first || create(:merchant)
      merchant.id
    }
    amount          10
  end
end
