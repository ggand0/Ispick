class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :name
      t.string :name_type
      t.integer :target_word_id

      t.timestamps
    end
  end
end
