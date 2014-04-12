class CreateTargetWords < ActiveRecord::Migration
  def change
    create_table :target_words do |t|
      t.string :word
      t.integer :user_id
      t.datetime :last_delivered_at
      t.boolean :enabled

      t.timestamps
    end
  end
end
