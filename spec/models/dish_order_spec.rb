require 'rails_helper'

RSpec.describe DishOrder, type: :model do
  before :each do
      @shipping = create :shipping, :default
      @dish = create :dish
      @customer = create :customer
      @payment = create :record_cash_payment, customer_id: @customer.id
  end
  context 'Single Thread' do
    describe 'place!' do
      it 'places an dish order' do
        expect {
          DishOrder.place! @shipping, @dish, 2, @customer, @payment
        }.to change(Order, :count).and change(Debt, :count).and \
          change(@dish, :order_count).by(2)
      end

      it 'puts an pending order request' do
        @dish.update_attribute :min_prepare_time, 24
        expect {
          DishOrder.place! @shipping, @dish, 2, @customer, @payment
        }.to change(Order, :count)
        expect(Transaction.count).to eq(0)
        expect(Debt.count).to eq(0)
        expect(@dish.reload.order_count).to eq(0)
        expect(Order.last.status).to eq(Order::STATUS_PENDING)
      end
    end

    describe 'cancel!' do
      before :each do
        @order = create :dish_order, :default, 
          customer_id: @customer.id, shipping_id: @shipping.id, 
          dish_id: @dish.id, payment_id: @payment.id
        @debt = create :debt, debtor_id: @customer.id,
          loaner_id: @dish.restaurant.merchant_id, amount: 100
      end

      it 'cancels the pending order' do
        @order.update_attribute :status, Order::STATUS_PENDING
        expect {
          @order.cancel!
        }.to_not change(Transaction, :count)
        expect(@debt.reload.amount).to eq(100)
        expect(@order.reload.status).to eq(Order::STATUS_CANCEL)
      end

      it 'cancels checkout order' do
        @dish.update_attribute :order_count, 5
        expect {
          @order.cancel!
        }.to change(Transaction, :count)
        expect(@dish.reload.order_count).to eq(5 - @order.quantity)
        expect(@debt.reload.amount).to eq(100 - @order.total_price)
        expect(@order.reload.status).to eq(Order::STATUS_CANCEL)
        transaction = Transaction.last
        expect(transaction.purpose).to eq(Transaction::TYPE_REFUND)
        expect(transaction.status).to eq(Transaction::STATUS_DONE)
      end

      it 'fails because not cancellable' do
        @order.update_attribute :status, Order::STATUS_DELIVERED
        expect {
          @order.cancel!
        }.to raise_error(Exceptions::NotEffective)
      end
    end
  end
  
  context 'Multithread', threaded: true do
    before :each do
      @debt = Debt.create debtor_id: @customer.id, 
        loaner_id: @dish.restaurant.merchant_id, amount: 0
    end

    describe 'place!' do
      it 'increments dish order count correctly' do
        20.times do |i|
          concurrency_test 4 do
            DishOrder.place! @shipping, @dish, 2, @customer, 
              @payment
          end
          expect(@dish.reload.order_count).to eq((i + 1) * 8)
          expect(@debt.reload.amount).to eq((i + 1) * 88)
        end
      end
    end

    describe 'cancel!' do
      it 'tests that no the order cannot be cancelled twice' do
        store = SpecHelpers::GlobalStore.new
        orders = []
        10.times do
          order = DishOrder.place! @shipping, @dish, 2, @customer, 
            @payment
          orders.append order.id
        end
        10.times do |round|
          concurrency_test 2 do
            order = DishOrder.find orders[round]
            begin
              order.cancel!
              store.write '0'
            rescue
              store.write '1'
            end
          end
        end
        expect(store.read.count '0').to eq(10)
      end

      it 'increments and decrement order count correctly' do
        # First add orders make sure there are enough orders to cancel
        20.times do
          DishOrder.place! @shipping, @dish, 2, @customer, @payment
        end
        20.times do |round|
          concurrency_test 4 do |i|
            if i != 1
              DishOrder.place! @shipping, @dish, 2, @customer,
                @payment
            else
              DishOrder.where(status: Order::STATUS_CHECKOUT)\
                .first.cancel!
            end
          end
          expect(@dish.reload.order_count).to eq(40 + (round + 1) * 4)
          expect(@debt.reload.amount).to eq((40 + (round + 1) * 4) * 11)
        end
      end
    end
  end
end
