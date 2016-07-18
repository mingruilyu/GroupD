class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :sender_id, null: false
      t.integer :receiver_id, null: false
      t.float   :amount, null: false, default: 0
      t.timestamps null: false
    end
  end
end
