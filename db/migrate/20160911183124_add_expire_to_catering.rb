class AddExpireToCatering < ActiveRecord::Migration
  def change
    add_column :caterings, :expire, :boolean, null: false, default: false
  end
end
