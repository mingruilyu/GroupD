require 'rails_helper'

describe Restaurant, type: :model do
  context 'Single Thread' do
    describe 'scopes' do
      it 'lists open restaurants of merchant' do
        restaurants = create_list :restaurant, 4, :unassociated
        restaurants[0].update_attribute :merchant_id, 100
        restaurants[2].update_attribute :status, 
          Restaurant::STATUS_CLOSED
        open_restaurants = Restaurant.open_by_merchant(
          restaurants[1].merchant_id)
        expect(open_restaurants.size).to eq(2)
      end
    end

    describe 'create!' do
      it 'create new restaurant' do
        restaurant = build :restaurant
        expect(restaurant).to be_valid
      end

      it 'fails because name not unique' do
        restaurant = create :restaurant, :unassociated
        expect{ 
          create :restaurant, name: restaurant.name
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'fails because image_url not present' do
        restaurant = build :restaurant, image_url: ''
        expect(restaurant).to_not be_valid
      end
    end
  end
end
