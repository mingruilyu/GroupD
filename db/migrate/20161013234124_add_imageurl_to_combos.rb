class AddImageurlToCombos < ActiveRecord::Migration
  def change
    add_column :combos, :image_url, :string, limit: 255
  end
end
