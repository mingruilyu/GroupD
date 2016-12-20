class RenameCateringToShipping < ActiveRecord::Migration
  def change
    rename_table :caterings, :shippings
  end
end
