class CreatePeopleTitles < ActiveRecord::Migration
  def change
    create_table :people_titles do |t|
      t.integer :title_id, null: false
      t.integer :person_id, null: false
    end
  end
end
