require 'rails_helper'

RSpec.describe Customers::DishOrdersController, type: :controller do

  context 'not logged in' do
    describe 'signin filter' do
      it 'fails because not signed in' do
        post :create, customer_id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context 'logged in' do
    before :each do
      @customer = login_customer
      @shipping = create :shipping, :unassociated
      @payment = create :record_cash_payment, customer_id: @customer.id
      @dish = create :dish
    end

    describe 'parameter validation' do
      it 'fails because payment not authorized' do
        payment = create :record_cash_payment, customer_id: 100
        post :create, customer_id: @customer.id, 
          shipping_id: @shipping.id, payment_id: payment.id, 
          quantity: 2, dish_id: @dish.id, format: :json 
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because customer does not exist' do
        post :create, customer_id: 100,
          shipping_id: @shipping.id, payment_id: @payment.id, 
          quantity: 2, dish_id: @dish.id, format: :json 
        expect(response).to have_http_status(:not_found)
      end

      it 'fails because shipping does not exist' do
        post :create, customer_id: @customer.id,
          shipping_id: 100, payment_id: @payment.id, 
          quantity: 2, dish_id: @dish.id, format: :json 
        expect(response).to have_http_status(:not_found)
      end

      it 'fails because shipping does not exist' do
        post :create, customer_id: @customer.id,
          shipping_id: @shipping.id, payment_id: @payment.id, 
          quantity: 2, dish_id: 100, format: :json 
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'POST create' do
      it 'create dish order' do
        post :create, customer_id: @customer.id, 
          shipping_id: @shipping.id, payment_id: @payment.id, 
          quantity: 2, dish_id: @dish.id, format: :json 
        expect(response).to have_http_status(:created)
      end
    end
  end
end

