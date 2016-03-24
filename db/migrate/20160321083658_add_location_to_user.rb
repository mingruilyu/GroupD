class AddLocationToUser < ActiveRecord::Migration
  def change
		add_column :users, :city_id, :integer, limit: 4, null: false, default: 1
  end
end
