class AddCountersToTags < ActiveRecord::Migration
  def change
    add_column :tags, :images_count, :integer, :default => 0, :null => false
    add_column :tags, :users_count, :integer, :default => 0, :null => false

    # Update counter values of existing records
    Tag.reset_column_information
    Tag.all.each do |tag|
      Tag.update_counters tag.id,
        :images_count => tag.images.length,
        :users_count => tag.users.length
    end
  end
end
