class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table(:events, id: false) do |t|
      t.string :id, primary_key: true
      t.string :name
      t.text :description

      t.datetime :end_date

      t.string :admin_email
      t.string :admin_token

      t.boolean :shadow_banned, default: false

      t.datetime :confirmed_at
      t.timestamps
    end
  end
end
