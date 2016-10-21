class AddAccountIdToCellphone < ActiveRecord::Migration
  def change
    add_column :cellphones, :account_id, :integer
  end
end
