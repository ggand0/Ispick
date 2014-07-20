class AddIndicesToTables < ActiveRecord::Migration
  def change
    add_index :people, [:name, :name_english, :name_display]
    add_index :keywords, [:word], :length => 10
    add_index :titles, [:name, :name_english], :length => 10
    add_index :people_titles, [:person_id, :title_id]
  end
end
