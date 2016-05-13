class ChangeMerchantsCellphoneToCellphoneId < ActiveRecord::Migration
  def change
    change_column :merchants, :cellphone, :integer, default: 0
  end
end
