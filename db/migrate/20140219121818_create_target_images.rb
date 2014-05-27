class CreateTargetImages < ActiveRecord::Migration
  def change
    create_table :target_images do |t|
      t.attachment :data
      t.integer :user_id
      t.datetime :last_delivered_at
      t.boolean :enabled

      t.timestamps
    end
  end
end
