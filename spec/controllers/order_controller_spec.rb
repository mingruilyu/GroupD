require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  
  before :each do
    login_customer
  end

  let(:account) { subject.current_account }

  describe 'GET index' do
    before :each do
      get :index, customer_id: account.id
    end

    it 'renders the index template' do
      expect(response).to render_template('index')
    end

    it 'assigns @customer' do
      expect(assigns(:customer)).to eq account
    end
  end

  describe 'GET new' do

    let(:cart) { subject.send(:current_cart) }
    
    context 'cart not empty' do
      before :each do
        create_list(:cart_item, 5, :dish_item, 
          cart_id: cart.id)
      end

      context 'shipping bound' do
        let(:shipping) { create(:shipping) }

        before :each do
          cart.shipping_id = shipping.id
          get :new, { customer_id: account.id }, { cart: cart.id }
        end

        it 'assigns @order with info' do
          order = Order.new(cart_id: cart.id, shipping_id: shipping.id)
          order.set_taxes(cart.total_price)
          order.total_price = cart.total_price + shipping.price \
            + order.taxes
          expect(assigns(:order).attributes).to eq order.attributes
        end

        it 'assigns @payments' do
          expect(assigns(:payments)).to_not be_nil
        end
      end

      context 'shipping not bound' do
        before :each do
          cart.shipping_id = nil
          get :new, { customer_id: account.id }, { cart: cart.id }
        end

        it 'renders the new template' do
          expect(response).to render_template('new')
        end
      
        it 'assigns empty @order' do
          order = Order.new(cart_id: cart.id)
          expect(assigns(:order).attributes).to eq order.attributes
        end
      end
    end

    context 'cart empty' do
      before :each do
        get :new, { customer_id: subject.current_account.id }
      end
      it 'add notice' do
        expect(flash[:notice]).to eq I18n.t('order.notice.CART_EMPTY')
      end

      it 'redirect to root path' do
        expect(response).to redirect_to(root_path)
      end

    end
  end
end
