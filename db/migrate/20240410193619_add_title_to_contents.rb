class AddTitleToContents < ActiveRecord::Migration[7.1]
  def change
    add_column :contents, :title, :string
  end
end
