class AddIndexToImagestags < ActiveRecord::Migration
  def change
    add_index :images_tags, [:tag_id]

    rename_column :features, :categ_imagenet, :convnet_feature
  end
end
