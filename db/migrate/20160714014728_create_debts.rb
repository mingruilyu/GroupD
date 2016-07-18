class CreateDebts < ActiveRecord::Migration
  def change
    create_table :debts do |t|
      t.integer :debtor_id, null: false
      t.integer :loaner_id, null: false
      t.float   :amount, null: false, default: 0
      t.timestamps null: false
    end
  end
end
