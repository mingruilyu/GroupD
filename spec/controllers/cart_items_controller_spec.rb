require 'rails_helper'

RSpec.describe CartItemsController, type: :controller do
  before :each do
    login_customer
  end

  describe 'GET new' do

    it 'renders the new template' do
      item = build(:cart_item)
      xhr :get, :new, cart_id: item.cart_id, catering_id: item.catering_id
      expect(response).to render_template('new')
    end
  end
end
