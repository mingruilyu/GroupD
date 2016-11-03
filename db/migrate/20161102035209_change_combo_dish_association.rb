class ChangeComboDishAssociation < ActiveRecord::Migration
  def change
    add_column :combos, :dishes, :text
  end
end
