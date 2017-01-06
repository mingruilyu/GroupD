class DropCombo < ActiveRecord::Migration
  def change
    drop_table :combos
  end
end
