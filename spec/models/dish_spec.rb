require 'rails_helper'

describe Dish, type: :model do
  it 'create dish' do
    dish = build(:dish)
    expect(dish).to be_valid
  end

  it 'should not create dish' do
    # name is missing
    dish = build(:dish, name: '')
    expect(dish).to_not be_valid
  end

  it 'should not create dish' do
    # image_url is missing
    dish = build(:dish, image_url: '')
    expect(dish).to_not be_valid
  end

  it 'should not create dish' do
    # price is negative
    dish = build(:dish, price: -0.1)
    expect(dish).to_not be_valid
  end
end
