class CreateDeliveredImages < ActiveRecord::Migration
  def change
    create_table :delivered_images do |t|
      t.text :title
      t.text :caption
      t.text :src_url
      t.attachment :data
      t.integer :user_id
      t.integer :favored_image_id
      t.integer :targetable_id
      t.string :targetable_type
      t.boolean :favored
      t.boolean :avoided

      t.timestamps
    end
  end
end
