class RemodelFood < ActiveRecord::Migration
  def change
    remove_column :foods, :available_until
    remove_column :foods, :type
    add_column :foods, :quota, :integer, default: 100
    add_column :foods, :is_combo, :boolean, default: true
  end
end
