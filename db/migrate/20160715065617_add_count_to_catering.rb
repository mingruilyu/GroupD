class AddCountToCatering < ActiveRecord::Migration
  def change
    add_column :caterings, :count, :integer, null: false, default: 0
  end
end
