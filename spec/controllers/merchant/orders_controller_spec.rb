require 'rails_helper'

RSpec.describe Merchants::OrdersController, type: :controller do
    
  context 'not logged in' do
    describe 'signin filter' do
      it 'fails authentication' do
        put :approve, merchant_id: 100, id: 10, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails authentication' do
        put :pickup, merchant_id: 100, id: 10, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context 'logged in' do
    before :each do
      @merchant = login_merchant
      restaurant = create :restaurant, :unassociated, 
        merchant_id: @merchant.id
      combo = create :combo
      @order = create :combo_order, :unassociated, 
        restaurant_id: restaurant.id, combo_id: combo.id
    end

    describe 'parameter validation' do
      it 'fails because restaurant not authorized' do
        @order.restaurant.update_attribute :merchant_id, 100
        @order.update_attribute :status, Order::STATUS_PENDING
        put :approve, merchant_id: @merchant.id, id: @order.id, 
          format: :json
        expect(response).to have_http_status(:unauthorized)
        @order.update_attribute :status, Order::STATUS_CHECKOUT
        put :pickup, merchant_id: @merchant.id, id: @order.id, 
          format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because merchant not authorized' do
        merchant = create :merchant, cellphone_id: 1
        put :approve, merchant_id: merchant.id, id: @order.id, 
          format: :json
        expect(response).to have_http_status(:unauthorized)
        put :pickup, merchant_id: merchant.id, id: @order.id, 
          format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because order does not exist' do
        put :approve, merchant_id: @merchant.id, id: 100, 
          format: :json
        expect(response).to have_http_status(:not_found)
        put :pickup, merchant_id: @merchant.id, id: 100, 
          format: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'PUT approve' do
      it 'approves pending combo order' do
        @order.update_attribute :status, Order::STATUS_PENDING
        put :approve, merchant_id: @merchant.id, id: @order.id, 
          format: :json
        expect(response).to have_http_status(:ok)
        expect(@order.reload.status).to eq(Order::STATUS_CHECKOUT)
      end

      it 'fails because combo order not pending' do
        put :approve, merchant_id: @merchant.id, id: @order.id, 
          format: :json
        expect(response).to have_http_status(:found)
        json = JSON.parse response.body
        expect(json['message']).to eq(generate_json_msg(:error,
          { 'status': [(I18n.t 'error.NOT_PENDING_FOR_APPROVAL')] }))
      end
    end

    describe 'PUT pickup' do
      before :each do
        @debt = create :debt, loaner_id: @merchant.id, 
          debtor_id: @order.customer_id, amount: @order.total_price
      end

      it 'fails because not checkout' do
        @order.update_attribute :status, Order::STATUS_PENDING
        put :pickup, merchant_id: @merchant.id, id: @order.id, 
          format: :json
        expect(response).to have_http_status(:found)
        json = JSON.parse(response.body)
        expect(json['message']).to eq(generate_json_msg(:error,
          { 'status': [(I18n.t 'error.PICKUP_ORDER_NOT_CHECKOUT')] }))
      end

      it 'only picks up' do
        put :pickup, merchant_id: @merchant.id, id: @order.id, 
          format: :json
        expect(response).to have_http_status(:ok)
        expect(@order.reload.status).to eq(Order::STATUS_DELIVERED)
        expect(@debt.reload.amount).to eq(@order.total_price)
      end
    end
  end
end
