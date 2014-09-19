class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.integer :image_id
      t.integer :user_id
      t.timestamps
    end

    add_column :users, :likes_count, :integer, :default => 0, :null => false
  end
end
