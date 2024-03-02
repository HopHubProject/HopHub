class CreateEntries < ActiveRecord::Migration[7.0]
  def change
    create_table(:entries, id: false) do |t|
      t.string :id, primary_key: true
      t.references :event, null: false, foreign_key: true, type: :string
      t.string :transport
      t.string :entry_type
      t.string :direction
      t.string :name
      t.string :email
      t.string :phone
      t.datetime :date
      t.decimal :latitude,  precision: 15, scale: 10
      t.decimal :longitude, precision: 15, scale: 10
      t.string :location
      t.integer :seats
      t.text :notes
      t.string :token
      t.datetime :confirmed_at
      t.string :locale

      t.timestamps
    end
  end
end
