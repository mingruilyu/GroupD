class ChangeCellphoneTokenDefaultValue < ActiveRecord::Migration
  def change
    change_column_default :cellphones, :confirmation_token, ""
  end
end
