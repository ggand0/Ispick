class AddColumnsToFavoredImages < ActiveRecord::Migration
  def change
    add_column :favored_images, :original_url, :text
    add_column :favored_images, :artist, :text
    add_column :favored_images, :poster, :text
  end
end
