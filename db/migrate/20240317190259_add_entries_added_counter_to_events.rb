class AddEntriesAddedCounterToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :entries_added, :integer, null: false, default: 0
  end
end
