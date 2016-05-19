class AddColumnsToCarts < ActiveRecord::Migration
  def change
    add_column :carts, :public_visible, :boolean, null: false, default: true
    add_column :carts, :user_id, :integer, limit: 11, null: false
  end
end
