class AddTypeToAccountAndChangeCellphoneDefaultValue < ActiveRecord::Migration
  def change
    add_column :accounts, :type, :integer, limit: 1, null: false, default: 0
    change_column_default :cellphones, :number, ""
  end
end
