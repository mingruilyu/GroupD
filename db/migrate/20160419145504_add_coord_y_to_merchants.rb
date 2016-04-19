class AddCoordYToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :coord_y, :float, defaul: 0.0
  end
end
