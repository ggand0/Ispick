class CreateImagesTargetWords < ActiveRecord::Migration
  def change
    create_table :images_target_words do |t|
      t.integer :image_id, null: false
      t.integer :target_word_id, null: false
    end
  end
end
