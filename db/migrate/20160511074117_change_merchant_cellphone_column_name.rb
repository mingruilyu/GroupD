class ChangeMerchantCellphoneColumnName < ActiveRecord::Migration
  def change
    rename_column :merchants, :cellphone, :cellphone_id
  end
end
