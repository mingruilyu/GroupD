class ChangeUserCellphoneIdType < ActiveRecord::Migration
  def change
    change_column :users, :cellphone_id, :integer, default: 0, null:false
  end
end
