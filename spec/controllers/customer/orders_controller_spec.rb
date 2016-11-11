require 'rails_helper'

RSpec.describe Customer::OrdersController, type: :controller do
  
  context 'not logged in' do
    describe 'signin filter' do
      it 'fails because not signed in' do
        get :index, customer_id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
      it 'fails because not signed in' do
        put :update, id: 1, format: :json 
        expect(response).to have_http_status(:unauthorized)
      end
      it 'fails because not signed in' do
        get :show, id: 1, payment_id: 0, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
      it 'fails because not signed in' do
        put :cancel, id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
      it 'fails because not signed in' do
        delete :destroy, id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context 'logged in' do

    before :each do
      login_customer
      @restaurant = create :restaurant
      @catering = create :catering, restaurant_id: @restaurant.id
      @account = subject.current_account
      @order = subject.send :current_order
    end

    describe 'parameter validation' do
      it 'fails because order does not exist' do
        put :update, id: 100, format: :json 
        expect(response).to have_http_status(:not_found)
        get :show, id: 100, format: :json
        expect(response).to have_http_status(:not_found)
        delete :destroy, id: 100, format: :json
        expect(response).to have_http_status(:not_found)
        put :cancel, id: 100, format: :json
        expect(response).to have_http_status(:not_found)
      end

      it 'fails because customer not authorized' do
        @order.update_attribute :customer_id, 100
        get :index, customer_id: 100, format: :json
        expect(response).to have_http_status(:not_found)
        put :update, id: @order.id, 
          payment_id: Payment::RECORD_CASH_ID, format: :json 
        expect(response).to have_http_status(:unauthorized)
        get :show, id: @order.id, format: :json
        expect(response).to have_http_status(:unauthorized)
        delete :destroy, id: @order.id, format: :json
        expect(response).to have_http_status(:unauthorized)
        put :cancel, id: @order.id, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because not modifying current order' do
        order = create :order, customer_id: @account.id
        put :update, id: order.id, 
          payment_id: Payment::RECORD_CASH_ID, format: :json 
        expect(response).to have_http_status(:unauthorized)
        delete :destroy, id: order.id, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because payment not authorized' do
        put :update, id: @order.id, payment_id: 100, format: :json 
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'GET index' do
      it 'gets customer history orders' do
        orders = create_list(:order, 5, customer_id: @account.id, 
          status: Order::STATUS_CHECKOUT)
        get :index, customer_id: @account.id, format: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['message']).to be_nil
        expect(json['object']).to eq(generate_json_list orders)
      end
    end

    describe 'PUT cancel' do
      it 'fails because current order not checked out' do
        put :cancel, id: @order.id, format: :json
        expect(response).to have_http_status(:found)
      end

      it 'cancels order' do
        @order.update_attribute :status, Order::STATUS_CHECKOUT
        @order.update_attribute :restaurant_id, @restaurant.id
        create(:order_item, order_id: @order.id,
          catering_id: @catering.id, quantity: 2)
        @catering.update_attribute :order_count, 2
        Debt.create loaner_id: @restaurant.merchant_id, 
          debtor_id: @account.id, amount: 100 
        expect{
          put :cancel, id: @order.id, format: :json
        }.to change(Transaction, :count) 
        expect(response).to have_http_status(:ok)
        expect(@order.reload.status).to eq(Order::STATUS_CANCEL)
        expect(@catering.reload.order_count).to eq(0)
      end
    end

    describe 'GET show' do
      it 'gets current order' do
        create_list(:order_item, 5, order_id: @order.id,
          catering_id: @catering.id, quantity: 2)
        get :show, id: @order.id, format: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['message']).to be_nil
        expect(json['object']).to eq(@order.as_json.stringify_keys)
      end
    end

    describe 'PUT update' do
      before :each do
        @order.update_attribute :customer_id, @account.id
      end

      it 'fails because items in order is empty' do
        put :update, id: @order.id, 
          payment_id: Payment::RECORD_CASH_ID, format: :json
        expect(response).to have_http_status(:found)
        json = JSON.parse(response.body)
        expect(json['message']).to eq(generate_json_msg(:error,
                                                        { 'status': [I18n.t('error.CHECK_EMPTY_ORDER')] }))
        expect(json['object']).to be_nil
      end

      it 'fails because items in order has expired' do
        caterings = create_list :catering, 5
        caterings.each do |catering|
          create(:order_item, order_id: @order.id, 
            catering_id: catering.id, quantity: 1)
        end
        caterings.first.update_attribute(:available_until, DateTime.now)
        put :update, id: @order.id, 
          payment_id: Payment::RECORD_CASH_ID, format: :json
        expect(response).to have_http_status(:gone)
        json = JSON.parse(response.body)
        expect(json['message']).to eq(generate_json_msg(:error, 
          { 'items': [I18n.t('error.CHECKOUT_EXPIRED_ITEM')] }))
        expect(json['object']).to be_nil
      end

      it 'fails because catering of the item in order cancelled' do
        create(:order_item, order_id: @order.id,
          catering_id: @catering.id, quantity: 2)
        @catering.destroy
        put :update, id: @order.id,
          payment_id: Payment::RECORD_CASH_ID, format: :json
        expect(response).to have_http_status(:gone)
        json = JSON.parse(response.body)
        expect(json['message']).to eq(generate_json_msg(:error,
          { 'items': [I18n.t('error.CHECKOUT_EXPIRED_ITEM')] }))
        expect(json['object']).to be_nil
      end

      it 'checkouts order when order has only one item' do
        create(:order_item, order_id: @order.id,
          catering_id: @catering.id, quantity: 2)
        @order.update_attribute :restaurant_id, @restaurant.id
        expect {
          put :update, id: @order.id, 
            payment_id: Payment::RECORD_CASH_ID, format: :json
        }.to change(Transaction, :count).and change(Debt, :count)
        @order.reload.status = Order::STATUS_CHECKOUT
        expect(response).to have_http_status(:ok)
        expect(@catering.reload.order_count).to equal(2)
        expect(session[:order]).to be_nil
      end

      it 'checkouts order when order has duplicate items' do
        create_list(:order_item, 5, order_id: @order.id,
          catering_id: @catering.id, quantity: 2)
        @order.update_attribute :restaurant_id, @restaurant.id
        expect {
          put :update, id: @order.id, 
            payment_id: Payment::RECORD_CASH_ID, format: :json
        }.to change(Transaction, :count).and change(Debt, :count)
        expect(response).to have_http_status(:ok)
        expect(@catering.reload.order_count).to equal(10)
        expect(session[:order]).to be_nil
      end
    end
  end
end
