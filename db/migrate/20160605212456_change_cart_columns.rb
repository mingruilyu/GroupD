class ChangeCartColumns < ActiveRecord::Migration
  def change
    change_column_null :carts, :shipping_id, true
    remove_column :carts, :public_visible
  end
end
