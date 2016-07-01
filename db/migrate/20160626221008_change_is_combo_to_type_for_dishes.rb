class ChangeIsComboToTypeForDishes < ActiveRecord::Migration
  def change
    remove_column :dishes, :is_combo
    add_column :dishes, :type, :string
  end
end
