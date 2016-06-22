class ChangeShippingCoordicateNull < ActiveRecord::Migration
  def change
    change_column_null :shippings, :coordinate_id, true 
  end
end
