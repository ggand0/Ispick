class CreateTargetImages < ActiveRecord::Migration
  def change
    create_table :target_images do |t|
      t.text :title

      t.timestamps
    end
  end
end
