class AddConfirmationToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :confirmed_at, :datetime, null: true
  end
end
