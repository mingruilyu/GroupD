require 'rails_helper'

describe Payment, type: :model do
  it 'should create payment' do
    payment = build(:payment)
    expect(payment).to be_valid
  end

  it 'should not create new payment' do
    # method not present
    payment = build(:payment, method: '')
    expect(payment).to_not be_valid
  end

  it 'should not create new payment' do
    # method not unique for the customer 
    payment = create(:payment)
    expect(build(:payment, customer_id: payment.customer.id)).to_not\
      be_valid
  end

  it 'should create payment' do
    payment = create(:payment)
    expect(build(:payment)).to be_valid
  end
end
