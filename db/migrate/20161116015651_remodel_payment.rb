class RemodelPayment < ActiveRecord::Migration
  def change
    rename_column :payments, :payment_type, :type
  end
end
