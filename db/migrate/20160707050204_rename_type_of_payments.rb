class RenameTypeOfPayments < ActiveRecord::Migration
  def change
    rename_column :payments, :type, :payment_type
  end
end
