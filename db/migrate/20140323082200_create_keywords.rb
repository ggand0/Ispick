class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.boolean :is_alias
      t.text :word
      t.integer :person_id

      t.timestamps
    end
  end
end
