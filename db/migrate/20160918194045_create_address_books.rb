class CreateAddressBooks < ActiveRecord::Migration
  def change
    create_table :address_books do |t|
      t.integer 'merchant_id', null: false
      t.integer 'building_id', null: false
      t.timestamps null: false
    end
  end
end
