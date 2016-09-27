require 'rails_helper'

RSpec.describe OrderItemsController, type: :controller do

  context 'not logged in' do
    describe 'signin filter' do
      it 'fails because not signed in' do
        delete :destroy, id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
        post :create, order_id: 1, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context 'logged in' do
    before :each do
      login_customer
    end

    let(:order) { subject.send(:current_order) }

    describe 'format sanitization' do
      it 'fails because not using json format' do
        delete :destroy, id: 1
        expect(response).to have_http_status(:not_found)
        post :create, order_id: 1
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'parameter validation' do
      it 'fails because order item does not exist' do
        delete :destroy, id: 100, format: :json 
        expect(response).to have_http_status(:not_found)
      end

      it 'fails because order does not exist' do
        post :create, order_id: 100, catering_id: 100, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because customer not authorized' do
        order = create :order
        order_item = create :order_item, order_id: 100
        post :create, order_id: order.id, catering_id: 100, 
          format: :json
        expect(response).to have_http_status(:unauthorized)
        delete :destroy, id: order_item.id, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'fails because catering does not exist' do
        post :create, order_id: order.id, order_item: { 
          catering_id: 1000 }
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'POST create' do

      let(:catering) { create(:catering) }

      it 'creates order item' do
        expect {
          post :create, order_id: order.id, order_item: { 
            catering_id: catering.id, quantity: 1 }, format: :json
        }.to change(OrderItem, :count).and change(
          order.reload.order_items, :count) 
        expect(response).to have_http_status(:created)
      end

      it 'fails because catering expired' do
        catering.update_attribute :available_until, Time.now 
        post :create, order_id: order.id, order_item: { 
          catering_id: catering.id }, format: :json
        expect(response).to have_http_status(:found)
        json = JSON.parse(response.body) 
        expect(json['message']).to eq(generate_json_msg(
          :error, Message::Error::CATERING_EXPIRED))

      end

      it 'fails because quantity is over limit' do
        post :create, order_id: order.id, order_item: { 
          catering_id: catering.id, quantity: 11 }, format: :json
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body) 
        expect(json['message']).to eq(generate_json_msg(:error, 
          Message::Error::QUANTITY_OVER_LIMIT))
      end

      it 'fails because quantity is under limit' do
        post :create, order_id: order.id, order_item: { 
          catering_id: catering.id, quantity: 0 }, format: :json
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body) 
        expect(json['message']).to eq(generate_json_msg(:error, 
          Message::Error::QUANTITY_OVER_LIMIT))
      end

      it 'fails because catering has expired' do
        catering.update_attribute :available_until, Time.now
        post :create, order_id: order.id, order_item: { 
          catering_id: catering.id, quantity: 1 }, format: :json
        expect(response).to have_http_status(:found)
        json = JSON.parse(response.body) 
        expect(json['message']).to eq(generate_json_msg(:error, 
          Message::Error::CATERING_EXPIRED))
      end
    end

    describe 'DELETE destroy' do
      it 'fails because item does not belongs current order' do
        item = create :order_item, order_id: 2
        delete :destroy, id: item.id, format: :json 
        expect(response).to have_http_status(:unauthorized)
      end

      it 'should destroy item' do
        item = create :order_item, order_id: order.id
        expect {
          delete :destroy, id: item.id, format: :json
        }.to change(order.reload.order_items, :count).by(-1)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
