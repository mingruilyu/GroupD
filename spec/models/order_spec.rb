require 'rails_helper'

RSpec.describe Order, type: :model do
  context 'Single Thread' do
    describe 'validations' do
      it 'fails because shipping is on the way' do
        shipping = create :shipping, :unassociated
        shipping.update_attribute :status, Shipping::STATUS_DEPART
        expect {
          create :order, :unassociated, shipping_id: shipping.id
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'fails because shipping not specified' do
        expect {
          create :order, :unassociated, shipping_id: nil
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe 'scopes' do
      before :each do
        @shipping = create :shipping, :unassociated
        @orders = create_list :order, 4, :default, customer_id: 1, shipping_id: @shipping.id
      end

      it 'lists orders by shipping' do
        @orders[0].update_attribute :shipping_id, 100
        orders = Order.by_shipping @orders[1].shipping_id
        expect(orders.size).to eq(3)
      end

      it 'lists orders by customer' do
        @orders[0].update_attribute :customer_id, 100
        orders = Order.by_customer @orders[1].customer_id
        expect(orders.size).to eq(3)
      end

      it 'lists orders by status' do
        @orders[0].update_attribute :status, Order::STATUS_PENDING
        orders = Order.by_status @orders[1].status
        expect(orders.size).to eq(3)
        expect(orders[1].status).to eq(Order::STATUS_CHECKOUT)
      end

      it 'lists checkout orders by customer' do
        @orders[0].update_attribute :customer_id, 100
        @orders[2].update_attribute :status, Order::STATUS_PENDING
        @orders[3].update_attributes status: Order::STATUS_DELIVERED, 
          customer_id: 100
        orders = Order.checkout_by_customer @orders[1].customer_id
        expect(orders.size).to eq(1)
        expect(orders.first.id).to eq(@orders[1].id)
      end

      it 'lists fulfilled orders by customer' do
        @orders[0].update_attribute :customer_id, 100
        @orders[1].update_attribute :status, Order::STATUS_FULFILLED
        @orders[2].update_attribute :status, Order::STATUS_PENDING
        @orders[3].update_attributes status: Order::STATUS_DELIVERED, 
          customer_id: 100
        orders = Order.fulfilled_by_customer @orders[1].customer_id
        expect(orders.size).to eq(1)
        expect(orders.first.id).to eq(@orders[1].id)
      end

      it 'lists cancellable orders by shipping' do
        @orders[0].update_attribute :shipping_id, 100
        @orders[1].update_attribute :status, Order::STATUS_CHECKOUT
        @orders[2].update_attribute :status, Order::STATUS_PENDING
        @orders[3].update_attributes status: Order::STATUS_DELIVERED, 
          shipping_id: @shipping.id
        orders = Order.cancellable_by_shipping @orders[1].shipping_id
        expect(orders.size).to eq(2)
      end

      it 'lists checkout orders by shipping' do
        @orders[0].update_attribute :shipping_id, 100
        @orders[2].update_attribute :status, Order::STATUS_PENDING
        @orders[3].update_attributes status: Order::STATUS_DELIVERED, 
          shipping_id: @shipping.id
        orders = Order.checkout_by_shipping @orders[1].shipping_id
        expect(orders.size).to eq(1)
        expect(orders.first.id).to eq(@orders[1].id)
      end

      it 'lists delivered orders by shipping' do
        @orders[0].update_attribute :shipping_id, 100
        @orders[1].update_attribute :status, Order::STATUS_DELIVERED
        @orders[2].update_attribute :status, Order::STATUS_PENDING
        orders = Order.delivered_by_shipping @orders[1].shipping_id
        expect(orders.size).to eq(1)
        expect(orders.first.id).to eq(@orders[1].id)
      end

      it 'counts order by shipping' do
        @orders.each do |order|
          order.update_attribute :shipping_id, @shipping.id
        end
        @orders[0].update_attribute :status, Order::STATUS_CHECKOUT
        @orders[1].update_attribute :status, Order::STATUS_CHECKOUT
        @orders[2].update_attribute :status, Order::STATUS_DELIVERED
        @orders[3].update_attribute :status, Order::STATUS_PENDING
        counts = Order.count_order_by_shipping @shipping.id
        expect(counts).to eq({
          Order::STATUS_CHECKOUT => 2,
          Order::STATUS_DELIVERED => 1 })
      end
    end

    context 'operations' do
      before :each do
        @food = create :food
        @shipping = create :shipping, :default, 
          restaurant_id: @food.restaurant_id, 
          estimated_arrival_at: (@food.min_prepare_time + 1).hour.from_now
        @customer = create :customer
        @payment = create :record_cash_payment, customer_id: @customer.id
      end

      describe 'place!' do
        it 'places an order with record cash payment' do
          expect {
            Order.place! @shipping, @food, 2, @customer, @payment
          }.to change(Order, :count).and change(Debt, :count).and \
            change(@food, :order_count).by(2)
        end

        it 'puts an pending order request because ddl is over' do
          @shipping.update_attribute :estimated_arrival_at, 
            (@food.min_prepare_time - 1).hour.from_now
          expect {
            Order.place! @shipping, @food, 2, @customer, @payment
          }.to change(Order, :count)
          expect(Transaction.count).to eq(0)
          expect(Debt.count).to eq(0)
          expect(@food.reload.order_count).to eq(0)
          expect(Order.last.status).to eq(Order::STATUS_PENDING)
        end

        it 'puts an pending order because food is sold out' do
          @food.update_attribute :quota, 1
          expect {
            Order.place! @shipping, @food, 2, @customer, @payment
          }.to change(Order, :count)
          expect(Transaction.count).to eq(0)
          expect(Debt.count).to eq(0)
          expect(@food.reload.order_count).to eq(0)
          expect(Order.last.status).to eq(Order::STATUS_PENDING)
        end
      end

      describe 'pickup!' do
        before :each do
          @order = Order.place! @shipping, @food, 2, @customer, @payment
        end
        it 'pickups the checkout order' do
          @order.pickup!
          expect(@order.reload.status).to eq(Order::STATUS_DELIVERED)
        end

        it 'fails because the order not checkout' do
          @order.update_attribute :status, Order::STATUS_PENDING
          expect {
            @order.pickup!
          }.to raise_error(Exceptions::NotEffective)
        end
      end

      describe 'approve!' do
        before :each do
          @food.update_attribute :quota, 0
          @order = Order.place! @shipping, @food, 2, @customer, 
            @payment
          @debt = create :debt, loaner_id: @food.restaurant.merchant_id, 
            debtor_id: @customer.id, amount: 0
        end

        it 'approves the pending order' do
          @order.approve!
          expect(@food.reload.order_count).to eq(2)
          expect(@debt.reload.amount).to eq(@order.total_price)
          expect(@order.reload.status).to eq(Order::STATUS_CHECKOUT)
        end

        it 'fails because order not pending' do
          @order.update_attribute :status, Order::STATUS_CHECKOUT
          expect {
            @order.approve!
          }.to raise_error(Exceptions::NotEffective)
          expect(@food.reload.order_count).to eq(0)
          expect(@debt.reload.amount).to eq(0)
        end
      end

      describe 'cancel!' do
        before :each do
          @order = create :order, :default, 
            customer_id: @customer.id, shipping_id: @shipping.id, 
            food_id: @food.id, payment_id: @payment.id
          @debt = create :debt, debtor_id: @customer.id,
            loaner_id: @food.restaurant.merchant_id, amount: 100
        end

        it 'cancels the pending order' do
          @order.update_attribute :status, Order::STATUS_PENDING
          expect {
            @order.cancel!
          }.to_not change(Transaction, :count)
          expect(@debt.reload.amount).to eq(100)
          expect(@order.reload.status).to eq(Order::STATUS_CANCELED)
        end

        it 'cancels checkout order' do
          @food.update_attribute :order_count, 5
          expect {
            @order.cancel!
          }.to change(Transaction, :count)
          expect(@food.reload.order_count).to eq(5 - @order.quantity)
          expect(@debt.reload.amount).to eq(100 - @order.total_price)
          expect(@order.reload.status).to eq(Order::STATUS_CANCELED)
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
  end
  
  context 'Multithread', threaded: true do
    before :each do
      @food = create :food
      @shipping = create :shipping, :default, 
          restaurant_id: @food.restaurant_id, 
          estimated_arrival_at: (@food.min_prepare_time + 1).hour.from_now
      @customer = create :customer
      @payment = create :record_cash_payment, customer_id: @customer.id
      @debt = Debt.create debtor_id: @customer.id, 
        loaner_id: @food.restaurant.merchant_id, amount: 0
    end

    describe 'place!' do
      it 'increments food order count correctly' do
        20.times do |i|
          concurrency_test 4 do
            Order.place! @shipping, @food, 2, @customer, 
              @payment
          end
          expect(@food.reload.order_count).to eq((i + 1) * 8)
          expect(@debt.reload.amount).to eq((i + 1) * 88)
        end
      end
    end

    describe 'cancel!' do
      it 'tests that no the order cannot be cancelled twice' do
        store = SpecHelpers::GlobalStore.new
        orders = []
        10.times do
          order = Order.place! @shipping, @food, 2, @customer, 
            @payment
          orders.append order.id
        end
        10.times do |round|
          concurrency_test 2 do
            order = Order.find orders[round]
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
          Order.place! @shipping, @food, 2, @customer, @payment
        end
        20.times do |round|
          concurrency_test 4 do |i|
            if i != 1
              Order.place! @shipping, @food, 2, @customer,
                @payment
            else
              Order.where(status: Order::STATUS_CHECKOUT)\
                .first.cancel!
            end
          end
          expect(@food.reload.order_count).to eq(40 + (round + 1) * 4)
          expect(@debt.reload.amount).to eq((40 + (round + 1) * 4) * 11)
        end
      end
    end
  end
end
