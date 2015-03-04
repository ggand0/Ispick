class CreateRecommendedTagsUsers < ActiveRecord::Migration
  def change
    create_table :recommended_tags_users do |t|
      t.integer :recommended_tag_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
