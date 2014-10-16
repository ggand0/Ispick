class AddDimensionToFavoredImages < ActiveRecord::Migration
  def change
    add_column :favored_images, :width, :integer, :default => 0, :null => false
    add_column :favored_images, :height, :integer, :default => 0, :null => false
  end
end
