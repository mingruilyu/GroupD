class ChangeCustomerColumnNull < ActiveRecord::Migration
  def change
    change_column_null :customers, :coordinate_id, true
    change_column_null :customers, :building_id, true
  end
end
