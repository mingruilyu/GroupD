require 'rails_helper'

RSpec.describe CartItemsController, type: :controller do

  let(:current_cart) { subject.send(:current_cart) }

  before :each do
    login_customer
  end

  describe 'input validation' do

    it 'fails because cart_id not valid' do
      cart = create :cart
      catering = create :catering
      xhr :get, :new, cart_id: cart.id, catering_id: catering.id
      expect(response.status).to eq(400)
    end

    it 'fails because catering_id not valid' do
      xhr :get, :new, cart_id: current_cart.id, catering_id: 10000
      expect(response.status).to eq(400)
      xhr :post, :create, cart_id: current_cart.id, 
        cart_item: { catering_id: 1000 }
      expect(response.status).to eq(400)
    end

  end

  describe 'GET new' do

    it 'renders the new template' do
      catering = create :catering
      current_cart.update restaurant_id: catering.restaurant_id
      xhr :get, :new, cart_id: current_cart.id, 
        catering_id: catering.id
      expect(response).to render_template('new')
      expect(assigns(:clear_all_confirmation)).to be_nil
    end

    it 'alert user for cart clear' do
      current_cart.update restaurant_id: 100
      catering = create :catering
      xhr :get, :new, cart_id: current_cart.id, 
        catering_id: catering.id
      expect(assigns(:clear_all_confirmation)).to eq(true)
    end
  end

  describe 'POST create' do

    let(:catering) { create(:catering) }

    it 'renders the create template' do
      xhr :post, :create, cart_id: current_cart.id,
        cart_item: { catering_id: catering.id, quantity: 1 }
      expect(response).to render_template('create')
    end

    it 'fails because quantity is too big' do
      xhr :post, :create, cart_id: current_cart.id,
        cart_item: { catering_id: catering.id, quantity: 11 }
      expect(response.status).to eq(400)
    end

    it 'fails because quantity is too small' do
      xhr :post, :create, cart_id: current_cart.id,
        cart_item: { catering_id: catering.id, quantity: 0 }
      expect(response.status).to eq(400)
    end

    it 'fails because catering has expired' do
      catering = create :catering, available_until: Time.now
      xhr :post, :create, cart_id: current_cart.id, 
        cart_item: { catering_id: catering.id, quantity: 1 }
      expect(response.status).to eq(400)
    end

  end

  describe 'DELETE destroy' do

    it 'fails because item not in cart' do
      item = create :cart_item, cart_id: 2
      xhr :delete, :destroy, cart_id: current_cart.id, id: item.id 
      expect(response.status).to eq(400)
    end

    it 'should destroy item' do
      item = create :cart_item, cart_id: current_cart.id
      xhr :delete, :destroy, cart_id: current_cart.id, id: item.id
      expect(response).to render_template('destroy')
      expect(current_cart.cart_items.size).to eq(0)
    end

  end
end
