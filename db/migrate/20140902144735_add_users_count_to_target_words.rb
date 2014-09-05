class AddUsersCountToTargetWords < ActiveRecord::Migration
  def change
    add_column :target_words, :users_count, :integer, :default => 0, :null => false
    add_column :target_words, :images_count, :integer, :default => 0, :null => false
    add_column :target_words, :crawl_count, :integer, :default => 0, :null => false
  end
end
