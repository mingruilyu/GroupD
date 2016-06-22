class CreateMerchants < ActiveRecord::Migration
  def change
    create_table :merchants do |t|
      t.integer "account_id", null: false
      t.timestamps null: false
    end
  end
end
