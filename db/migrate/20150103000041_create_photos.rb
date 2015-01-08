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

      t.timestamps
    end
  end
end
