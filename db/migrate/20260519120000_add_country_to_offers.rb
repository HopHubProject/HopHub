class AddCountryToOffers < ActiveRecord::Migration[8.1]
  def up
    add_column :offers, :country, :string

    execute <<~SQL
      UPDATE offers
      SET country = events.default_country
      FROM events
      WHERE offers.event_id = events.id
    SQL
  end

  def down
    remove_column :offers, :country
  end
end
