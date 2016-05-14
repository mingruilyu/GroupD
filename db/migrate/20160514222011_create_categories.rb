class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string    :name, limit: 255, null: false 
      t.timestamps null: false
    end
  end
end
