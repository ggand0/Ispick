class FixColumnName < ActiveRecord::Migration
  def change
    rename_column :target_words, :word, :name
  end
end
