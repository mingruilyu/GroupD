class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string "name", limit: 255, null: false
      t.timestamps null: false
    end
  end
end
