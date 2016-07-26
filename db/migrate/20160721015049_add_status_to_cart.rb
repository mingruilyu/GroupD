class AddStatusToCart < ActiveRecord::Migration
  def change
    add_column :carts, :status, :boolean, null: false, default: false
  end
end
