class AddViewCountsToImages < ActiveRecord::Migration
  def change
    rename_column :images, :views, :original_view_count
    rename_column :images, :favorites, :original_favorite_count
    rename_column :favored_images, :views, :original_view_count
    rename_column :favored_images, :favorites, :original_favorite_count
    add_column :images, :view_count, :integer, :default => 0, :null => false
    add_column :images, :clip_count, :integer, :default => 0, :null => false
    add_column :images, :share_count, :integer, :default => 0, :null => false
  end
end
