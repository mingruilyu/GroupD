class AddTokenAuthSupport < ActiveRecord::Migration
  def change
    add_column :accounts, :uid, :string, null: false, default: ''
    add_column :accounts, :provider, :string, null: false
    add_column :accounts, :tokens, :text

    add_index :accounts, [:uid, :provider], unique: true
  end
end
