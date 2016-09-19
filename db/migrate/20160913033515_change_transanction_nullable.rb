class ChangeTransanctionNullable < ActiveRecord::Migration
  def change
    change_column_null :orders, :transaction_id, null: true
  end
end
