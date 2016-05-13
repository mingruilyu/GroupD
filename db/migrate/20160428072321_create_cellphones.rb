class CreateCellphones < ActiveRecord::Migration
  def change
    create_table :cellphones do |t|
      t.string :number, null: false, default: "0000000000", limit: 20
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :confirmation_token, null: false, default: "000000", limit: 10
      t.timestamps null: false
    end
  end
end
