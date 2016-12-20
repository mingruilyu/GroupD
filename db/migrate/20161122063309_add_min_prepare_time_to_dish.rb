class AddMinPrepareTimeToDish < ActiveRecord::Migration
  def change
    add_column :dishes, :min_prepare_time, :integer, limit: 2, null: false, default: 24
  end
end
