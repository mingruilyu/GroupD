class ChangeNullForDishIdInCartItem < ActiveRecord::Migration
  def change
    change_column_null :cart_items, :dish_id, true
  end
end
