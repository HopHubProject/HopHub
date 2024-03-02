class AddDriverToEntries < ActiveRecord::Migration[7.1]
  def change
    add_column :entries, :driver, :boolean, null: false, default: false
  end
end
