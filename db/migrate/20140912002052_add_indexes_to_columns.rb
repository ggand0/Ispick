class AddIndexesToColumns < ActiveRecord::Migration
  def change
    add_index :images, [:md5_checksum, :created_at]
    add_index :images, :src_url, length: 255
    add_index :people, [:target_word_id]
    add_index :tags, [:name]
    add_index :images_tags, [:image_id]
  end
end
