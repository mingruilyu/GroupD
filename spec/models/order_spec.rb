require 'rails_helper'

RSpec.describe Order, type: :model do
  context 'Single Thread' do
    describe 'validation' do
      it 'fails because shipping has expired' do
        shipping = create :shipping, :default
        shipping.update_attribute :status, Shipping::STATUS_DEPART
        expect {
          create :combo_order, :unassociated, shipping_id: shipping.id
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe 'scopes' do
      before :each do
        shipping = create :shipping, :unassociated
        @orders = create_list :combo_order, 4, :unassociated, 
          shipping_id: shipping.id
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
        shipping = create :shipping, :unassociated
        @orders[0].update_attribute :shipping_id, shipping.id
        @orders[1].update_attribute :status, Order::STATUS_CHECKOUT
        @orders[2].update_attribute :status, Order::STATUS_PENDING
        @orders[3].update_attributes status: Order::STATUS_DELIVERED, 
          shipping_id: shipping.id
        orders = Order.cancellable_by_shipping @orders[1].shipping_id
        expect(orders.size).to eq(2)
      end

      it 'lists checkout orders by shipping' do
        shipping = create :shipping, :unassociated
        @orders[0].update_attribute :shipping_id, shipping.id
        @orders[2].update_attribute :status, Order::STATUS_PENDING
        @orders[3].update_attributes status: Order::STATUS_DELIVERED, 
          shipping_id: shipping.id
        orders = Order.checkout_by_shipping @orders[1].shipping_id
        expect(orders.size).to eq(1)
        expect(orders.first.id).to eq(@orders[1].id)
      end

      it 'lists delivered orders by shipping' do
        shipping = create :shipping, :unassociated
        @orders[0].update_attribute :shipping_id, shipping.id
        @orders[1].update_attribute :status, Order::STATUS_DELIVERED
        @orders[2].update_attribute :status, Order::STATUS_PENDING
        orders = Order.delivered_by_shipping @orders[1].shipping_id
        expect(orders.size).to eq(1)
        expect(orders.first.id).to eq(@orders[1].id)
      end

      it 'counts order by shipping' do
        shipping = create :shipping, :unassociated
        @orders.each do |order|
          order.update_attribute :shipping_id, shipping.id
        end
        @orders[0].update_attribute :status, Order::STATUS_CHECKOUT
        @orders[1].update_attribute :status, Order::STATUS_CHECKOUT
        @orders[2].update_attribute :status, Order::STATUS_DELIVERED
        @orders[3].update_attribute :status, Order::STATUS_PENDING
        counts = Order.count_order_by_shipping shipping.id
        expect(counts).to eq({
          Order::STATUS_CHECKOUT => 2,
          Order::STATUS_DELIVERED => 1 })
      end
    end

    describe 'cancel!' do
      it 'cancels the order' do
        restaurant = create :restaurant, :unassociated
        combo = create :combo, restaurant_id: restaurant.id
        payment = create :record_cash_payment, customer_id: 1
        order = create :combo_order, :unassociated, customer_id: 1, 
          combo_id: combo.id, restaurant_id: restaurant.id, 
          payment_id: payment.id
        debt = create :debt, loaner_id: restaurant.merchant_id, 
          debtor_id: order.customer_id, amount: 100
        expect {
          order.cancel!
        }.to change(Transaction, :count)
        expect(order.reload.status).to eq(Order::STATUS_CANCEL)
        expect(debt.reload.amount).to eq(100 - order.total_price)
      end
    end

    describe 'pickup!' do
      it 'pickup' do
        order = create :combo_order, :unassociated
        order.pickup!
        expect(order.reload.status).to eq(Order::STATUS_DELIVERED)
      end
    end
  end
end
