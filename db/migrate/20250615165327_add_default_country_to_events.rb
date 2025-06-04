class AddDefaultCountryToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :default_country, :string
  end
end
