class AddColumnsToImages < ActiveRecord::Migration
  def change
    add_column :images, :popularity, :integer
    add_column :images, :popularity_anipic, :integer
    add_column :images, :original_width, :integer
    add_column :images, :original_height, :integer
    add_column :images, :original_views, :integer
    add_column :images, :original_favorites, :integer
    add_column :favored_images, :original_width, :integer
    add_column :favored_images, :original_height, :integer
  end
end
