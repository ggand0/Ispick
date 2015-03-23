class AddLanguageToTags < ActiveRecord::Migration
  def change
    add_column :tags, :language, :string, :default => 'english', :null => false
  end
end
