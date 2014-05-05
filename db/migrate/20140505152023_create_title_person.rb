class CreateTitlePerson < ActiveRecord::Migration
  def change
    create_table :title_people, id: false do |t|
      t.integer :title_id, null: false
      t.integer :person_id, null: false
    end
  end
end
