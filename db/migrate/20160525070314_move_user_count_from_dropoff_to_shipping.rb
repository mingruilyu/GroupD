class MoveUserCountFromDropoffToShipping < ActiveRecord::Migration
  def change
    remove_column :dropoffs, :user_count
    add_column :shippings, :user_count, :integer, null: false, default: 0
  end
end
