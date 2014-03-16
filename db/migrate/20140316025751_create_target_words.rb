class CreateTargetWords < ActiveRecord::Migration
  def change
    create_table :target_words do |t|
      t.string :word

      t.timestamps
    end
  end
end
