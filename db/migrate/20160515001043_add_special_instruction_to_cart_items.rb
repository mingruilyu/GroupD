class AddSpecialInstructionToCartItems < ActiveRecord::Migration
  def change
    add_column :cart_items, :special_instruction, :text
  end
end
