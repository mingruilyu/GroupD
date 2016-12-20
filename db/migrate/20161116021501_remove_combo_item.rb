class RemoveComboItem < ActiveRecord::Migration
  def change
    drop_table :combo_items
    add_column :combos, :available_until, :datetime
  end
end
