require 'rails_helper'

RSpec.describe Shipping, type: :model do
  context 'Single Thread' do
    describe 'scopes' do
      before :each do
        @shippings = create_list :shipping, 4, :unassociated
      end

      it 'lists active shippings' do
        @shippings[0].update_attribute :status, Shipping::STATUS_DEPART
        shippings = Shipping.active
        expect(shippings.size).to eq(3)
      end

      it 'lists shippings by restaurant' do
        @shippings[0].update_attribute :restaurant_id, 100
        shippings = Shipping.by_restaurant @shippings[1].restaurant_id
        expect(shippings.size).to eq(3)
      end

      it 'lists shippings by building' do
        @shippings[0].update_attribute :building_id, 100
        shippings = Shipping.by_building @shippings[1].building_id
        expect(shippings.size).to eq(3)
      end

      it 'lists active shippings by restaurant' do
        @shippings[0].update_attribute :status, Shipping::STATUS_CANCELLED
        @shippings[2].update_attribute :restaurant_id, 100
        @shippings[3].update_attributes status: Shipping::STATUS_ARRIVE, 
          restaurant_id: 100
        shippings = Shipping.active_by_restaurant @shippings[1].restaurant_id
        expect(shippings.size).to eq(1)
        expect(shippings.first.id).to eq(@shippings[1].id)
      end

      it 'lists active shippings by building' do
        @shippings[0].update_attribute :status, Shipping::STATUS_CANCELLED
        @shippings[2].update_attribute :building_id, 100
        @shippings[3].update_attributes status: Shipping::STATUS_ARRIVE, 
          building_id: 100
        shippings = Shipping.active_by_building @shippings[1].building_id
        expect(shippings.size).to eq(1)
        expect(shippings.first.id).to eq(@shippings[1].id)
      end
    end

    describe 'batch_create!' do
      it 'creates a batch of shippings' do
        buildings = create_list :building, 3
        restaurant = create :restaurant, :unassociated
        time = 1.day.from_now
        deliver_time = time.month * 1000000 + time.day * 10000 + 1230
        expect {
          Shipping.batch_create! buildings, restaurant, deliver_time
        }.to change(Shipping, :count).by(3)
      end
    end

    describe 'edit!' do
      it 'updates arrival time of the shipping' do
        shipping = create :shipping, :unassociated
        time = 2.day.from_now
        shipping.edit! time.month * 1000000 + time.day * 10000 + 1130
        expect(shipping.reload.estimated_arrival_at.to_s(:db)).to eq(
          Time.now.change(month: time.month, day: time.day, hour: 11, 
          min: 30).utc.to_s(:db))
      end
    end

    describe 'cancel!' do
      it 'cancels the shipping as well as all caterings' do
        restaurant = create :restaurant, :unassociated
        combo = create :combo, restaurant_id: restaurant.id
        shipping = create :shipping, :unassociated
        payment = create :record_cash_payment, customer_id: 1
        orders = create_list :combo_order, 3, :unassociated, 
          shipping_id: shipping.id, combo_id: combo.id, 
          restaurant_id: restaurant.id, payment_id: payment.id, 
          customer_id: 1
        debt = create :debt, loaner_id: restaurant.merchant_id, 
          debtor_id: orders[0].customer_id
        orders[0].update_attribute :status, Order::STATUS_PENDING
        caterings = create_list :catering, 3, shipping_id: shipping.id
        expect {
          shipping.cancel!
        }.to change(Catering, :count).by(-3)
        expect(shipping.reload.status).to eq(Shipping::STATUS_CANCELLED)
        orders.each do |order|
          expect(order.reload.status).to eq(Order::STATUS_CANCEL) 
        end
      end
    end

    describe 'update_state!' do
      it 'updates shipping state' do
        shippings = create_list :shipping, 4, :unassociated
        shippings[0].update_attribute :status, Shipping::STATUS_WAITING
        shippings[1].update_attribute :status, Shipping::STATUS_DEPART
        shippings[2].update_attribute :status, Shipping::STATUS_ARRIVE
        shippings[3].update_attribute :status, Shipping::STATUS_PICKING_UP
        shippings.each do |shipping|
          shipping.update_state!
        end
        expect(shippings[0].reload.status).to eq(Shipping::STATUS_DEPART)
        expect(shippings[1].reload.status).to eq(Shipping::STATUS_ARRIVE)
        expect(shippings[2].reload.status).to eq(Shipping::STATUS_PICKING_UP)
        expect(shippings[3].reload.status).to eq(Shipping::STATUS_FULFILLED)
      end

      it 'fails because shipping cancelled' do
        shipping = create :shipping, :unassociated, 
          status: Shipping::STATUS_CANCELLED
        expect {
          shipping.update_state!
        }.to raise_error(Exceptions::NotEffective)
      end
    end
  end

  context 'Multithread', threaded: true do
    describe 'cancel! and add order' do
      it 'either cancel or add order' do
        shippings = create_list :shipping, 20, :default
        combo = create :combo
        customer = create :customer
        payment = create :record_cash_payment, customer_id: customer.id
        20.times do |round|
          concurrency_test 2 do |i|
            delay_random_time
            if i == 0
              begin
                ComboOrder.place! shippings[round], combo, 2, customer, 
                  payment
              rescue Exception => e
                puts 'failure in creation ' + e.to_s
              end
            else
              shippings[round].cancel!
            end
          end
          expect(shippings[round].reload.status).to eq(
            Shipping::STATUS_CANCELLED)
          expect(combo.reload.order_count).to eq(0)
        end
      end
    end
  end
end
