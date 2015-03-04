class CreateRecommendedTags < ActiveRecord::Migration
  def change
    create_table :recommended_tags do |t|
      t.string :name
      t.integer :images_count, :default => 0, :null => false

      t.timestamps
    end

    # RecommendedTag has_one Tag
    add_column :tags, :recommended_tag_id, :integer
  end
end
