class ChangeNullForCateringIdInCartItem < ActiveRecord::Migration
  def change
    change_column_null :cart_items, :catering_id, true
  end
end
