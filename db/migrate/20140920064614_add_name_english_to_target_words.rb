class AddNameEnglishToTargetWords < ActiveRecord::Migration
  def change
    add_column :target_words, :name_english, :text
  end
end
