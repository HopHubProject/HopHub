class CreateRideRequests < ActiveRecord::Migration[8.0]
  def change
    create_table(:ride_requests, id: false) do |t|
      t.string :id, primary_key: true
      t.references :event, null: false, foreign_key: true, type: :string
      t.string :direction
      t.string :email
      t.string :location
      t.string :country
      t.decimal :latitude,  precision: 15, scale: 10
      t.decimal :longitude, precision: 15, scale: 10
      t.integer :radius
      t.datetime :end_date
      t.string :token
      t.datetime :confirmed_at
      t.string :locale

      t.timestamps
    end
  end
end
