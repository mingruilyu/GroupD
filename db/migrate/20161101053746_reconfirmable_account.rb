class ReconfirmableAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :unconfirmed_email, :string, null: true
  end
end
