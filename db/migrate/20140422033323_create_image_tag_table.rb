class CreateImageTagTable < ActiveRecord::Migration
  def change
    create_table :images_tags, id: false do |t|
      t.integer :image_id, null: false
      t.integer :tag_id, null: false
    end
  end
end
