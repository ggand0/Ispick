class AddColumnToTitles < ActiveRecord::Migration
  def change
    add_column :titles, :id_anidb, :integer
  end
end
