class AddOwnerNameToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :owner_name, :string, default: ""
  end
end
