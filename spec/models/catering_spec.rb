require 'rails_helper'

RSpec.describe Catering, type: :model do
  context 'Single Thread' do
    describe 'validation' do
      it 'fails because timing not correct for combo and shipping' do
        combo = create :combo, available_until: 10.hour.from_now
        shipping = create :shipping, :unassociated
        expect {
          Catering.create! shipping_id: shipping.id, combo_id: combo.id
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe 'scopes' do
      before :each do
        combo = create :combo
        shipping = create :shipping, :unassociated
        @caterings = create_list :catering, 3, combo_id: combo.id, 
          shipping_id: shipping.id
      end

      it 'lists catering by combo' do
        @caterings[0].update_attribute :combo_id, 100 
        caterings = Catering.by_combo @caterings[1].combo_id
        expect(caterings.size).to eq(2)
      end

      it 'lists catering by shipping' do
        @caterings[0].update_attribute :shipping_id, 100
        caterings = Catering.by_shipping @caterings[1].shipping_id
        expect(caterings.size).to eq(2)
      end
    end
  end
end
