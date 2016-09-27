class ChangeOrderColumnNullable < ActiveRecord::Migration
  def change
    change_column_null :orders, :total_price, null: false
  end
end
