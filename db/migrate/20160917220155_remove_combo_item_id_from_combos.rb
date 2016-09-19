class RemoveComboItemIdFromCombos < ActiveRecord::Migration
  def change
    remove_column :combos, :combo_item_id
  end
end
