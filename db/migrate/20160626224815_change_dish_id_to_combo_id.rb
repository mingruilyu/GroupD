class ChangeDishIdToComboId < ActiveRecord::Migration
  def change
    rename_column :caterings, :dish_id, :combo_id
  end
end
