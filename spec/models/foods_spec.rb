require 'rails_helper'

RSpec.describe Food, type: :model do
  context 'Single Thread' do
    describe 'validations' do
      it 'fails because name is empty' do
        food = build :food, name: ''
        expect(food).to_not be_valid
      end

      it 'fails because name is invalid' do
        food = build :food, name: 'Tariyaki Chicken' * 50
        expect(food).to_not be_valid
      end

      it 'fails because name is not unique' do
        food = create :food
        expect {
          create :food, name: food.name
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'succeeds because foods are under different restaurant scope' do
        food = create :food, restaurant_id: 1
        expect {
          create :food, name: food.name, restaurant_id: 2
        }.not_to raise_error
      end

      it 'fails because image_url is empty' do
        food = build :food, image_url: ''
        expect(food).to_not be_valid
      end

      it 'fails because image_url is invalid' do
        food = build :food, image_url: 'a.b.c'
        expect(food).to_not be_valid
      end

      it 'fails because price is invalid' do
        food = build :food, price: -0.1
        expect(food).to_not be_valid
      end
    end

    describe 'scopes' do
      before :each do
        @foods = create_list :food, 4
      end

      it 'lists foods by restaurant' do
        @foods[0].update_attribute :restaurant_id, 100
        foods = Food.by_restaurant @foods[1].restaurant_id
        expect(foods.size).to eq(3)
      end

      it 'lists active foods by restaurant' do
        @foods[0].update_attribute :restaurant_id, 100
        @foods[2].update_attribute :quota, 0
        @foods[3].update_attribute :min_prepare_time, 
          @foods[1].min_prepare_time + 2
        foods = Food.active_by_restaurant @foods[1].restaurant_id, 
          (@foods[1].min_prepare_time + 1).hour.from_now
        expect(foods.size).to eq(1)
        expect(foods.first.id).to eq(@foods[1].id)
      end
    end

    describe 'add!' do
      it 'creates a food' do
        expect {
          Food.add! restaurant_id: 100, price: 10, 
            image_url: 'http://www.food.com', name: 'Tariyaki Chicken'
        }.to change(Food, :count)
      end
    end

    describe 'update!' do
      it 'updates the food' do
        food = create :food
        food.update! price: 12, image_url: 'http://www.dish.com'
        expect(food.reload.price).to eq(12)
        expect(food.image_url).to eq('http://www.dish.com')
      end
    end

    describe 'cancel!' do
      it 'cancels the food as well as all associated orders' do
        food = create :food
        payment = create :record_cash_payment
        debt = create :debt, loaner_id: food.restaurant.merchant_id, 
         debtor_id: payment.customer_id
        orders = create_list :order, 2, :default, food_id: food.id, 
          customer_id: payment.customer_id, payment_id: payment.id
        orders[0].update_attribute :customer_id, payment.customer_id
        orders[1].update_attribute :status, Order::STATUS_PENDING
        food.cancel!
        expect(orders[0].reload.status).to eq(Order::STATUS_CANCELED)
        expect(orders[1].reload.status).to eq(Order::STATUS_CANCELED)
        expect(food.reload.status).to eq(Food::STATUS_CANCELED)
      end
    end
  end

  context 'Multithread', threaded: true do
    describe 'cancel! and add order' do
      it 'either cancel or add order' do
        foods = create_list :food, 20
        shipping = create :shipping, :default, 
          restaurant_id: foods[0].restaurant_id
        customer = create :customer
        payment = create :record_cash_payment, 
          customer_id: customer.id
        20.times do |round|
          concurrency_test 2 do |i|
            delay_random_time
            if i == 0
              begin
                Order.place! shipping, foods[round], 2, customer, 
                  payment
              rescue Exception => e
                puts 'failure in creation ' + e.to_s
              end
            else
              begin
                foods[round].cancel!
              rescue Exception => e
                puts 'failure in cancel ' + e.to_s
              end
            end
          end
          expect(foods[round].reload.status).to eq(
            Food::STATUS_CANCELED)
          expect(foods[round].order_count).to eq(0)
        end
      end
    end
  end
end
