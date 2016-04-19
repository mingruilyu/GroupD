class AddPropertiesToUser < ActiveRecord::Migration
  def change
			add_column	:users,	:telephone, :string, limit: 20, null: false, default: ""
			add_column	:users, :company_id, :integer, limit: 11
			add_index 	:users, :telephone
  end
end
