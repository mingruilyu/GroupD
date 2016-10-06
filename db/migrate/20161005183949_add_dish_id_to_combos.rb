class AddDishIdToCombos < ActiveRecord::Migration
  def change
    add_column :combos, :dish_1, :integer
    add_column :combos, :dish_2, :integer
    add_column :combos, :dish_3, :integer
    add_column :combos, :dish_4, :integer
    add_column :combos, :dish_5, :integer
  end
end
