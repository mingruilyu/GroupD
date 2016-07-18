class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :dish
  belongs_to :catering

  def is_dish?
    self.dish_id.present?
  end

  def is_combo?
    self.catering_id.present?
  end
end
