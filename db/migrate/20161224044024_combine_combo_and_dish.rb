class CombineComboAndDish < ActiveRecord::Migration
  def change
    rename_table :dishes, :foods
    add_column :foods, :type, :string, default: 'Combo', null: false
    add_column :foods, :available_until, :datetime
    drop_table :caterings
  end
end
