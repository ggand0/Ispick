class CreateFavoredImages < ActiveRecord::Migration
  def change
    create_table :favored_images do |t|
      t.text :title
      t.text :caption
      t.text :src_url
      t.integer :user_id

      t.timestamps
    end
  end
end
