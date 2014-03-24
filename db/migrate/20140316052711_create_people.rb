class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :name            # ”鹿目まどか”
      t.string :display_name    # "鹿目まどか（かなめ まどか）"
      t.string :name_type       # "Character"
      t.integer :target_word_id

      t.timestamps
    end
  end
end
