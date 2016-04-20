class AddCoordXToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :coord_x, :float, default: 0.0
  end
end
