class Catering < ActiveRecord::Base
  belongs_to :shipping
  belongs_to :combo

  validate :shipping_valid_for_combo

  private

    def shipping_valid_for_combo
      # combo's available_until should earlier than 
      #   (MIN_SHIPPING_TIME + MIN_PREPARE_TIME) to the shipping's 
      #   estimated_arrival_at time
      self.errors[:time] = I18n.t 'error.CATERING_TIME_INVALID' if \
        (self.combo.available_until + (Shipping::MIN_SHIPPING_TIME + \
          Combo::MIN_PREPARE_TIME).minute) > \
          self.shipping.estimated_arrival_at
    end
end
