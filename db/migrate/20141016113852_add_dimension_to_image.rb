class AddDimensionToImage < ActiveRecord::Migration
  def change
    add_column :images, :width, :integer, :default => 0, :null => false
    add_column :images, :height, :integer, :default => 0, :null => false
  end
end
