class CreateTargetWordUsers < ActiveRecord::Migration
  def change
    create_table :target_word_users do |t|

      t.timestamps
    end
  end
end
