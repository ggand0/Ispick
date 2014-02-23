class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.string :face
      t.integer :featurable_id
      t.string :featurable_type

      t.timestamps
    end
  end
end
