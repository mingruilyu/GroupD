class Changeusercellphone < ActiveRecord::Migration
  def change
    rename_column :users, :cellphone, :cellphone_id
    remove_column :users, :confirmed_at, :datetime
    remove_column :users, :confirmation_sent_at, :datetime
    remove_column :users, :confirmation_token, :string, limit: 255
  end
end
