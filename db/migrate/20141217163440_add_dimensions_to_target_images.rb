class AddDimensionsToTargetImages < ActiveRecord::Migration
  def change
    add_column :target_images, :width, :integer
    add_column :target_images, :height, :integer
  end
end
