class ChangeColumnsInRecommendedTags < ActiveRecord::Migration
  def change
    # Don't need this as we can refer to RecommendedTag.tag.images_count indirectly instead
    remove_column :recommended_tags, :images_count

    # We do need the number of co-occurrence for a good recommendation
    add_column :recommended_tags, :cooccurrence_count, :integer
  end
end
