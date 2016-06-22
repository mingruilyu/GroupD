class ChangeAccountTypeType < ActiveRecord::Migration
  def change
    change_column :accounts, :type, :string
  end
end
