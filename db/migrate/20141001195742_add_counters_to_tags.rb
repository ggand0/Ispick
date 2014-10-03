class AddCountersToTags < ActiveRecord::Migration
  def change
    #add_column :tags, :images_count, :integer, :default => 0, :null => false
    #add_column :tags, :users_count, :integer, :default => 0, :null => false

    # Update counter values of existing records
    Tag.reset_column_information
    count = Tag.count
    first = Tag.first.id
    start = Tag.where.not(images_count: 0).last.id
    tags = Tag.where("id > ?", start)
    tags.each do |tag|
      if tag.images_count > 0  # Consider non-zero counters as it's already added.
        puts "Skipped: #{tag.id-first}/#{count}"
        next
      end
      Tag.update_counters tag.id,
        :images_count => tag.images.length,
        :users_count => tag.users.length
      puts "Added counters to tag.id=#{tag.id-first}/#{count}"
    end
  end
end
