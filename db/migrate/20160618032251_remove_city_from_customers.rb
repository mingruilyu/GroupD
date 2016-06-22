class RemoveCityFromCustomers < ActiveRecord::Migration
  def change
    remove_column :customers, :city_id
  end
end
