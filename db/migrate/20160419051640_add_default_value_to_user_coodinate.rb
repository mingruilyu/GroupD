class AddDefaultValueToUserCoodinate < ActiveRecord::Migration
  def change
    change_column_default :users, :current_coord_x, 0.0
    change_column_default :users, :current_coord_y, 0.0
    end
end
