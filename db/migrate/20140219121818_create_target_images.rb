class CreateTargetImages < ActiveRecord::Migration
  def change
    create_table :target_images do |t|
      t.string :title

      t.timestamps
    end
  end
end
