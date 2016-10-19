class AddDefaultToProvider < ActiveRecord::Migration
  def change
    change_column_default :accounts, :provider, 'development'
  end
end
