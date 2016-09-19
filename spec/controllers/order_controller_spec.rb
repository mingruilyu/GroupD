require 'rails_helper'

RSpec.describe OrdersController, type: :controller do

  context 'not logged in' do
    describe 'signin filter' do
      it 'fails because not signed in' do
        get :index, { customer_id: 1 } 
        expect(response).to render_template('common/force_signin')
        get :new, { customer_id: 1 } 
        expect(response).to render_template('common/force_signin')
        post :create, { customer_id: 1, payment_id: 0 } 
        expect(response).to render_template('common/force_signin')
      end
    end
  end

  context 'logged in' do

    before :each do
      login_customer
    end

    let(:bad_request_path) { "#{Rails.root}/public/400.html" } 
    let(:account) { subject.current_account } 
    let(:cart) { subject.send(:current_cart) }

    describe 'input validation' do
      it 'fails because customer_id not valid' do
        get :new, { customer_id: 100 }
        expect(response).to render_template(
          file: bad_request_path)
        get :index, { customer_id: 100 }
        expect(response).to render_template(
          file: bad_request_path)
        post :create, { customer_id: 100 }
        expect(response).to render_template(
          file: bad_request_path)
        customer = create(:customer)
        get :index, { customer_id: customer.id }
        expect(response).to render_template(
          file: bad_request_path)
        get :new, { customer_id: customer.id }
        expect(response).to render_template(
          file: bad_request_path)
        post :create, { customer_id: customer.id }
        expect(response).to render_template(
          file: bad_request_path)
      end

      it 'fails because payment_id not valid' do
        post :create, customer_id: account.id, order:{ payment_id: 100 } 
        expect(response).to render_template(
          file: bad_request_path)
      end
    end
    describe 'GET index' do
      it 'renders the index template' do
        create_list(:order, 5, customer_id: account.id)
        get :index, { customer_id: account.id }
        expect(response).to render_template('index')
        expect(assigns(:orders).size).to eq(5)
      end
    end

    describe 'POST create' do

      let (:cart) { subject.send('current_cart') }
      
      it 'fails because items in cart is empty' do
        post :create, customer_id: account.id, order: {
          payment_id: Payment::RECORD_CASH_ID }
        expect(response).to redirect_to(root_path)
      end

      it 'fails because items in cart have expired' do
        caterings = create_list :catering, 5
        caterings.each do |catering|
          create(:cart_item, cart_id: cart.id, 
            catering_id: catering.id, quantity: 1)
        end
        caterings.first.update_attribute(:available_until, DateTime.now)
        post :create, customer_id: account.id, order: {
          payment_id: Payment::RECORD_CASH_ID }
        expect(response).to redirect_to(root_path)
      end

      it 'creates order when cart has only one item' do
        restaurant = create :restaurant
        catering = create :catering
        create(:cart_item, cart_id: cart.id,
          catering_id: catering.id, quantity: 2)
        cart.update_attribute :restaurant_id, restaurant.id
        expect {
          post :create, customer_id: account.id, order: {
            payment_id: Payment::RECORD_CASH_ID }
        }.to change(Order, :count)
        catering.reload
        expect(catering.order_count).to equal(2)
        expect(session[:cart]).to be_nil
      end

      it 'creates order when cart has duplicate items' do
        restaurant = create :restaurant
        catering = create :catering
        create_list(:cart_item, 5, cart_id: cart.id,
          catering_id: catering.id, quantity: 2)
        cart.update_attribute :restaurant_id, restaurant.id
        expect {
          post :create, customer_id: account.id, order: {
            payment_id: Payment::RECORD_CASH_ID }
        }.to change(Order, :count)
        catering.reload
        expect(catering.order_count).to equal(10)
        expect(session[:cart]).to be_nil
      end
    end

    describe 'GET new' do
      it 'redircts to root_path because cart is empty' do
        get :new, customer_id: account.id
        expect(response).to redirect_to(root_path)
      end

      it 'renders new template' do
        restaurant = create :restaurant
        catering = create :catering
        create_list(:cart_item, 5, cart_id: cart.id,
          catering_id: catering.id, quantity: 2)
        cart.update_attribute :restaurant_id, restaurant.id
        get :new, customer_id: account.id
        expect(response).to render_template('new')
      end
    end
  end
end
