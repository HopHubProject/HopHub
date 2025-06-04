class DropEntryEntryType < ActiveRecord::Migration[8.0]
  def change
    remove_column :entries, :entry_type, :string
  end
end
