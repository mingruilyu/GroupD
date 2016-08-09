require 'rails_helper'

describe Shipping, type: :model do
  it 'create new shipping' do
    shipping = build(:shipping)
    expect(shipping).to be_valid
  end

  it 'does not create new shipping' do
    # time diff between deadline and shipping time is not enough
    shipping = build(:shipping, 
      available_until: (3.hour + 5.minute).from_now)
    expect(shipping).to_not be_valid
  end

  it 'does not create new shipping' do
    # deadline in the past
    shipping = build(:shipping, available_until: 3.minute.ago)
    expect(shipping).to_not be_valid
  end

end
