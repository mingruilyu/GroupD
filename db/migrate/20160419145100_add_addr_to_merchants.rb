class AddAddrToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :addr, :string, default: ""
  end
end
