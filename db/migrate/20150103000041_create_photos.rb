class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      # Basic data
      t.text :title
      t.text :caption
      t.text :src_url
      t.boolean :is_illust
      t.float :quality
      t.attachment :data
      t.string :md5_checksum

      # Additional data
      t.text :page_url
      t.text :site_name
      t.string :module_name
      t.integer :views
      t.integer :favorites
      t.datetime :posted_at

      t.integer  :original_view_count
      t.integer  :original_favorite_count
      t.datetime :posted_at
      t.datetime :created_at
      t.datetime :updated_at
      t.text     :artist
      t.text     :original_url
      t.text     :poster
      t.integer  :original_width
      t.integer  :original_height

      t.timestamps
    end
  end
end
