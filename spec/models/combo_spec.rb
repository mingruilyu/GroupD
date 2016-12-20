require 'rails_helper'

RSpec.describe Combo, type: :model do
  context 'Single Thread' do
    describe 'scopes' do
      before :each do
        @combos = create_list :combo, 4
      end

      it 'lists combos by restaurant' do
        @combos[0].update_attribute :restaurant_id, 100
        combos = Combo.by_restaurant @combos[1].restaurant_id
        expect(combos.size).to eq(3)
      end

      it 'lists active combos by restaurant' do
        @combos[0].update_attribute :restaurant_id, 100
        @combos[2].update_attribute :status, Combo::STATUS_END
        @combos[3].update_attribute :status, Combo::STATUS_END
        combos = Combo.active_by_restaurant @combos[1].restaurant_id
        expect(combos.size).to eq(1)
        expect(combos.first.id).to eq(@combos[1].id)
      end
    end

    describe 'create!' do
      it 'creates a combo' do
        month = Time.now.month
        day = Time.now.day
        available_until = month * 1000000 + day * 10000 + 1100
        dishes = create_list :dish, 3
        expect {
          Combo.create! dishes, dishes[0].restaurant, 10, 
            'www.food.com', available_until
        }.to change(Combo, :count)
      end
    end

    describe 'update!' do
      it 'updates the combo' do
        dishes = create_list :dish, 3
        combo = create :combo
        month = Time.now.month
        day = Time.now.day
        available_until = month * 1000000 + day * 10000 + 1100
        combo.update! dishes, 12, 'www.food.com', available_until
        dish_ids = []
        dishes.each do |dish|
          dish_ids.append dish.id
        end
        expect(combo.reload.dishes).to eq(dish_ids)
        expect(combo.price).to eq(12)
      end
    end

    describe 'cancel!' do
      it 'cancels the combo as well as all associated caterings' do
        combo = create :combo
        caterings = create_list :catering, 3, combo_id: combo.id
        expect {
          combo.cancel!
        }.to change(Catering, :count).by(-3)
        expect(combo.reload.status).to eq(Combo::STATUS_CANCEL)
      end
    end
  end

  context 'Multithread', threaded: true do
    describe 'cancel! and add order' do
      it 'either cancel or add order' do
        combos = create_list :combo, 20
        shipping = create :shipping, :default
        customer = create :customer
        payment = create :record_cash_payment, customer_id: customer.id
        20.times do |round|
          concurrency_test 2 do |i|
            delay_random_time
            if i == 0
              begin
                ComboOrder.place! shipping, combos[round], 2, customer, 
                  payment
              rescue Exception => e
                puts 'failure in creation ' + e.to_s
              end
            else
              begin
                combos[round].cancel!
              rescue Exception => e
                puts 'failure in cancel ' + e.to_s
              end
            end
          end
          expect(combos[round].reload.status).to eq(Combo::STATUS_CANCEL)
          expect(combos[round].order_count).to eq(0)
        end
      end
    end
  end
end
