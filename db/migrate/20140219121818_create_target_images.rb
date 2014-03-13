class CreateTargetImages < ActiveRecord::Migration
  def change
    create_table :target_images do |t|
      t.text :title
      t.integer :user_id

      t.timestamps
    end
  end
end
