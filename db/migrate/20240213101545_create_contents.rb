class CreateContents < ActiveRecord::Migration[7.1]
  def change
    create_table :contents do |t|
      t.string :name
      t.string :locale
      t.boolean :fallback
      t.text :content

      t.timestamps
    end
  end
end
