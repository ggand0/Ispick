class AddUsersCountToTargetWords < ActiveRecord::Migration
  def change
    add_column :target_words, :crawl_count, :integer, :default => 0, :null => false
    add_column :target_words, :images_count, :integer, :default => 0, :null => false
    add_column :target_words, :users_count, :integer, :default => 0, :null => false

    # Update counter values of existing records
    TargetWord.reset_column_information
    TargetWord.all.each do |target_word|
      TargetWord.update_counters target_word.id,
        :images_count => target_word.images.length,
        :users_count => target_word.users.length
    end
  end
end
