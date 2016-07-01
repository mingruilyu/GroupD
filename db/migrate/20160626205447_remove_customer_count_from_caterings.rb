class RemoveCustomerCountFromCaterings < ActiveRecord::Migration
  def change
    remove_column :caterings, :customer_count
  end
end
