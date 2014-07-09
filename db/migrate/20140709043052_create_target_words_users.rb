class CreateTargetWordsUsers < ActiveRecord::Migration
  def change
    create_table :target_words_users, id: false do |t|
      t.integer :target_word_id, null: false
      t.integer :user_id, null: false
    end
  end
end
