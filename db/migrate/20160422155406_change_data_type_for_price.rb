class ChangeDataTypeForPrice < ActiveRecord::Migration
  def change
    change_column(:dishes, :price, :decimal, precision: 8, scale: 2) 
  end
end
