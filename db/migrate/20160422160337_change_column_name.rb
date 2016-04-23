class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :merchants, :tel, :cellphone
  end
end
