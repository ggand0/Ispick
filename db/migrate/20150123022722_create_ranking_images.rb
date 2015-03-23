class CreateRankingImages < ActiveRecord::Migration
  def change
    create_table :ranking_images do |t|
      # Only has a reference
      t.integer :image_id
      t.timestamps
    end
  end
end
