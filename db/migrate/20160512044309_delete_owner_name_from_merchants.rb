class DeleteOwnerNameFromMerchants < ActiveRecord::Migration
  def change
    remove_column :merchants, :owner_name, limit: 255, default: ""
  end
end
