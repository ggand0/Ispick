class CreateUserTargetWords < ActiveRecord::Migration
  def change
    create_table :user_target_words do |t|

      t.timestamps
    end
  end
end
