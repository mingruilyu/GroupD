class RemoveCellphoneFromAccount < ActiveRecord::Migration
  def change
    change_column_null :accounts, :cellphone_id, null: true
  end
end
