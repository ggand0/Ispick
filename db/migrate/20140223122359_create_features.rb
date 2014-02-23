class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.string :face

      t.timestamps
    end
  end
end
