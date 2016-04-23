class ChangeTelephoneToCellphoneInUsers < ActiveRecord::Migration
  def change
		rename_column :users, :telephone, :cellphone
  end
end
