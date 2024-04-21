class RenameEntriesAddedToOfferedSeatsTotal < ActiveRecord::Migration[7.1]
  def change
    rename_column :events, :entries_added, :seats_added_total
  end
end
