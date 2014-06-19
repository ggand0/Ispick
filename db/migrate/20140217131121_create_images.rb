class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      # 基本的な情報
      t.text :title
      t.text :caption
      t.text :src_url
      t.boolean :is_illust
      t.float :quality
      t.attachment :data
      t.string :md5_checksum

      # 付加的な情報
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
