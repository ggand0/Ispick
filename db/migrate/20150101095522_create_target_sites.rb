class CreateTargetSites < ActiveRecord::Migration
  def change
    create_table :target_sites do |t|
      t.string :name

      t.timestamps
    end
  end
end
