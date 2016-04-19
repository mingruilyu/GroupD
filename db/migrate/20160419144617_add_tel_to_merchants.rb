class AddTelToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :tel, :string, default: ""
  end
end
