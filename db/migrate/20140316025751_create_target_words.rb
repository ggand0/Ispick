class CreateTargetWords < ActiveRecord::Migration
  def change
    create_table :target_words do |t|
      t.string :word
      t.datetime :last_delivered_at
      t.datetime :newest_scraped_at
      t.datetime :oldest_scraped_at

      t.timestamps
    end
  end
end
