class AddColumnsToTables < ActiveRecord::Migration
  def change
    add_column :images, :original_url, :text
    add_column :users, :language, :string
  end
end
