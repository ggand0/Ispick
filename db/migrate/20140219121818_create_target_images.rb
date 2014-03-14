class CreateTargetImages < ActiveRecord::Migration
  def change
    create_table :target_images do |t|
      t.text :title
      t.integer :user_id
      t.datetime :last_delivered_at

      t.timestamps
    end
  end
end
