class CreateImagesTargetImages < ActiveRecord::Migration
  def change
    create_table :images_target_images do |t|
      t.integer :image_id, null: false
      t.integer :target_image_id, null: false
    end

    add_column :target_images, :images_count, :integer, :default => 0, :null => false
  end
end
