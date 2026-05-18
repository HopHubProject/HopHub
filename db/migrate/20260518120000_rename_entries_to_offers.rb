class RenameEntriesToOffers < ActiveRecord::Migration[8.1]
  def change
    rename_table :entries, :offers
  end
end
