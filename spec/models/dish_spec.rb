require 'rails_helper'

RSpec.describe Dish, type: :model do
  context 'Single Thread' do
    describe 'scopes' do
      it 'lists active dish by restaurant' do
        dishes = create_list :dish, 4
        dishes[0].update_attribute :restaurant_id, 100
        dishes[1].update_attribute :status, Dish::STATUS_CANCELED
        active_dishes = Dish.active_by_restaurant dishes[1].restaurant_id
        expect(active_dishes.size).to eq(2)
      end
    end
    
    describe 'create!' do
      it 'create a dish' do
        expect {
          Dish.create! restaurant_id: 1, name: 'Tariyaki Chicken', 
            price: 10, image_url: 'http://www.dish.com', 
            desc: 'This is delicious'
        }.to change(Dish, :count)
      end
  
      it 'fails because name is empty' do
        dish = build(:dish, name: '')
        expect(dish).to_not be_valid
      end

      it 'fails because name is invalid' do
        dish = build(:dish, name: 'Tariyaki Chicken' * 50)
        expect(dish).to_not be_valid
      end

      it 'fails because name is not unique' do
        dish = create :dish
        expect {
          create :dish, name: dish.name
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'fails because image_url is empty' do
        dish = build(:dish, image_url: '')
        expect(dish).to_not be_valid
      end

      it 'fails because image_url is invalid' do
        dish = build(:dish, image_url: 'a.b.c')
        expect(dish).to_not be_valid
      end

      it 'fails because price is invalid' do
        dish = build(:dish, price: -0.1)
        expect(dish).to_not be_valid
      end
    end
  end

  context 'MultiThread', threaded: true do
    describe 'cancel! and add order' do
      it 'either cancel or add order' do
        dishes = create_list :dish, 20
        shipping = create :shipping, :default
        customer = create :customer
        payment = create :record_cash_payment, customer_id: customer.id
        20.times do |round|
          concurrency_test 2 do |i|
            delay_random_time
            if i == 0
              begin
                DishOrder.place! shipping, dishes[round], 2, customer, 
                  payment
              rescue Exception => e
                puts 'failure in creation ' + e.to_s
              end
            else
              begin
                dishes[round].cancel!
              rescue Exception => e
                puts 'failure in cancel ' + e.to_s
              end
            end
          end
          expect(dishes[round].reload.status).to eq(Dish::STATUS_CANCELED)
          expect(dishes[round].order_count).to eq(0)
        end
      end
    end
  end
end
