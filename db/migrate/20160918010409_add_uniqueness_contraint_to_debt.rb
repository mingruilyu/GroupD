class AddUniquenessContraintToDebt < ActiveRecord::Migration
  def change
    add_index :debts, [:loaner_id, :debtor_id], unique: true
  end
end
