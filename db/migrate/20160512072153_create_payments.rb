class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer     :merchant_id,   null: false
      t.integer     :type,          limit: 1,   null: false,  default: 0
      t.string      :method,        limit: 255, null: false,  default: ""
      t.timestamps null: false
    end
  end
end
