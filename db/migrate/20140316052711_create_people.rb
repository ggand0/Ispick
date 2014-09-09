class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :name            # ”鹿目まどか”
      t.string :name_display    # "鹿目 まどか"
      t.string :name_roman      # "Kaname Madoka"
      t.string :name_english    # "Madoka Kaname"
      t.string :name_type       # "Character"

      t.integer :target_word_id # TargetWordにhas_oneされている

      t.timestamps
    end
  end
end
