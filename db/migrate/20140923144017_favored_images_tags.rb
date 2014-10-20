class FavoredImagesTags < ActiveRecord::Migration
  def change
    create_table :favored_images_tags do |t|
      t.integer :favored_image_id, null: false
      t.integer :tag_id, null: false
    end
  end
end
