require 'rails_helper'

RSpec.describe Customers::OrdersController, type: :controller do
  
  context 'not logged in' do
    describe 'signin filter' do
      it 'fails because not signed in' do
        get :index, customer_id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
      it 'fails because not signed in' do
        get :show, id: 1, customer_id: 100, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
      it 'fails because not signed in' do
        put :cancel, id: 1, customer_id: 100, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context 'logged in' do

    before :each do
      @customer = login_customer
    end

    describe 'parameter validation' do
      it 'fails because order does not exist' do
        get :show, customer_id: @customer.id, id: 100, format: :json
        expect(response).to have_http_status(:not_found)
        put :cancel, customer_id: @customer.id, id: 100, format: :json
        expect(response).to have_http_status(:not_found)
      end

      it 'fails because customer not authorized' do
        customer = create :customer
        get :index, customer_id: customer.id, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because order not authorized' do
        order = create :combo_order, :unassociated, customer_id: 100
        get :show, customer_id: @customer.id, id: order.id, format: :json
        expect(response).to have_http_status(:unauthorized)
        put :cancel, customer_id: @customer.id, id: order.id, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe 'GET index' do
      it 'gets customer history orders' do
        orders = create_list(:combo_order, 5, :unassociated, 
          customer_id: @customer.id, status: Order::STATUS_CHECKOUT)
        get :index, customer_id: @customer.id, format: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['message']).to be_nil
        expect(json['object']).to eq(generate_json_list orders)
      end
    end

    describe 'PUT cancel' do
      before :each do
        payment = create :record_cash_payment, customer_id: @customer.id
        combo = create :combo
        dish = create :dish
        @combo_order = create :combo_order, :unassociated, 
          combo_id: combo.id, customer_id: @customer.id, 
          restaurant_id: combo.restaurant_id, payment_id: payment.id
        @dish_order = create :dish_order, :unassociated, 
          dish_id: dish.id, customer_id: @customer.id,
          restaurant_id: dish.restaurant_id, payment_id: payment.id
      end

      it 'fails because order delivered' do
        @combo_order.update_attribute :status, Order::STATUS_DELIVERED
        put :cancel, customer_id: @customer.id, id: @combo_order.id, 
          format: :json
        expect(response).to have_http_status(:found)
        json = JSON.parse(response.body)
        expect(json['message']).to eq(generate_json_msg(:error, 
        {
          status: [I18n.t('error.ORDER_NOT_CANCELLABLE')]
        }))
      end

      it 'cancels combo order' do
        Debt.create loaner_id: @combo_order.restaurant.merchant_id, 
          debtor_id: @customer.id, amount: 100 
        expect{
          put :cancel, customer_id: @customer.id, id: @combo_order.id, 
            format: :json
        }.to change(Transaction, :count) 
        expect(response).to have_http_status(:ok)
        expect(@combo_order.reload.status).to eq(Order::STATUS_CANCEL)
      end

      it 'cancels combo order' do
        Debt.create loaner_id: @dish_order.restaurant.merchant_id, 
          debtor_id: @customer.id, amount: 100 
        expect{
          put :cancel, customer_id: @customer.id, id: @dish_order.id, 
            format: :json
        }.to change(Transaction, :count) 
        expect(response).to have_http_status(:ok)
        expect(@dish_order.reload.status).to eq(Order::STATUS_CANCEL)
      end
    end

    describe 'GET show' do
      it 'gets current order' do
        order = create :combo_order, :unassociated, customer_id: @customer.id
        get :show, customer_id: @customer.id, id: order.id, format: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['message']).to be_nil
        expect(json['object']).to eq(order.as_json.stringify_keys)
      end
    end
  end
end
