class CreateDeliveredImages < ActiveRecord::Migration
  def change
    create_table :delivered_images do |t|
      t.text :title
      t.text :caption
      t.text :src_url
      t.integer :user_id
      t.boolean :favored
      t.boolean :avoided

      t.timestamps
    end
  end
end
