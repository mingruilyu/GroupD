require 'rails_helper'

describe Restaurant, type: :model do
  it 'create new restaurant' do
    restaurant = build(:restaurant) 
    expect(restaurant).to be_valid
  end

  it 'does not creat new restaurant' do
    # name not unique
    create(:restaurant)
    expect{ build(:restaurant) }.to raise_error(
      ActiveRecord::RecordInvalid)
  end

  it 'does not create new restaurant' do
    # open close time not valid
    restaurant = build(:restaurant, open_at: 1400, close_at: 1000)
    expect(restaurant).to_not be_valid
  end

  it 'does not create new restaurant' do
    # image urls not present
    restaurant = build(:restaurant, image_url: '')
    expect(restaurant).to_not be_valid
  end

  it 'does not create new restaurant' do
    # certificate url not present
    restaurant = build(:restaurant, certificate_url: '')
    expect(restaurant).to_not be_valid
  end

end
