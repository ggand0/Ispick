class AddColumnToFavoredImages < ActiveRecord::Migration
  def change
    add_column :favored_images, :page_url, :text
    add_column :favored_images, :site_name, :text
    add_column :favored_images, :views, :integer
    add_column :favored_images, :favorites, :integer
    add_column :favored_images, :posted_at, :datetime
  end
end
