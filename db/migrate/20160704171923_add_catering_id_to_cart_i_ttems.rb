class AddCateringIdToCartITtems < ActiveRecord::Migration
  def change
    add_column :cart_items, :catering_id, :integer, null: false
  end
end
