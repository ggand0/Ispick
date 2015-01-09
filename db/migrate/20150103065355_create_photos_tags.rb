class CreatePhotosTags < ActiveRecord::Migration
  def change
    create_table :photos_tags do |t|
      t.integer :photo_id, null: false
      t.integer :tag_id, null: false
    end
  end
end
