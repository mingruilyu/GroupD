class ChangePaymentTypeToString < ActiveRecord::Migration
  def change
    change_column :payments, :type, :string
  end
end
