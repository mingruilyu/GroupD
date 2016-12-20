class CombineOrderOrderItem < ActiveRecord::Migration
  def change
    add_column    :orders, :type, :string
  end
end
