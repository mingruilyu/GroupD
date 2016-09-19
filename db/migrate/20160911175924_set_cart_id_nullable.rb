class SetCartIdNullable < ActiveRecord::Migration
  def change
    change_column_null :cart_items, :cart_id, true
  end
end
