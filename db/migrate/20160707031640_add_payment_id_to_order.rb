class AddPaymentIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :payment_id, :integer, null: false
  end
end
