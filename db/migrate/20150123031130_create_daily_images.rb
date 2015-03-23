class CreateDailyImages < ActiveRecord::Migration
  def change
    create_table :daily_images do |t|
      # Copy the important attributes from an image
      t.integer :image_id
      t.attachment :data

      t.text     :title
      t.text     :caption
      t.text     :src_url
      t.text     :page_url
      t.text     :original_url
      t.text     :site_name
      t.integer  :original_view_count
      t.integer  :original_favorite_count
      t.datetime :posted_at
      t.text     :artist
      t.text     :poster
      t.integer  :original_width
      t.integer  :original_height
      t.integer  :width,                   default: 0, null: false
      t.integer  :height,                  default: 0, null: false

      t.timestamps
    end
  end
end
