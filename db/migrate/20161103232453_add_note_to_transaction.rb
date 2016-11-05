class AddNoteToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :note, :text
  end
end
