class FixAuthor < ActiveRecord::Migration
  def change
    rename_column :images, :author, :artist
    add_column :images, :poster, :text
    add_column :users, :language_preferences, :string
  end
end
