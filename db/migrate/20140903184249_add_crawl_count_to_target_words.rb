class AddCrawlCountToTargetWords < ActiveRecord::Migration
  def change
    add_column :target_words, :crawl_count, :integer, :default => 0, :null => false
  end
end
