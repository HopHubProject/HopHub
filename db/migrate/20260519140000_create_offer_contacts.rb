class CreateOfferContacts < ActiveRecord::Migration[8.1]
  def up
    create_table :offer_contacts do |t|
      t.references :offer, null: false, foreign_key: true, type: :string
      t.string :kind, null: false
      t.string :value, null: false
      t.timestamps
    end

    # Backfill from offers.phone — any non-blank value becomes a phone contact.
    now = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S.%6N")
    execute <<~SQL
      INSERT INTO offer_contacts (offer_id, kind, value, created_at, updated_at)
      SELECT id, 'phone', phone, '#{now}', '#{now}'
      FROM offers
      WHERE phone IS NOT NULL AND phone <> ''
    SQL

    remove_column :offers, :phone
  end

  def down
    add_column :offers, :phone, :string

    execute <<~SQL
      UPDATE offers
      SET phone = (
        SELECT value FROM offer_contacts
        WHERE offer_contacts.offer_id = offers.id AND offer_contacts.kind = 'phone'
        LIMIT 1
      )
    SQL

    drop_table :offer_contacts
  end
end
