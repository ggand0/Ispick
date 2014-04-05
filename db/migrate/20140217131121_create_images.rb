class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      # 基本的な情報
      t.text :title
      t.text :caption
      t.text :src_url
      t.boolean :is_illust
      t.attachment :data
      t.string :md5_checksum

      # 付加的な情報
      t.text :page_url
      t.text :site_name
      t.integer :view_nums
      t.datetime :posted_time

      t.timestamps
    end
  end
end
