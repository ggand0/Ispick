class CreatePeopleKeywords < ActiveRecord::Migration
  def change
    create_table :people_keywords do |t|
      t.integer :keyword_id, null: false
      t.integer :person_id, null: false
    end
  end
end
