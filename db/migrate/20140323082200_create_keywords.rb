class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.boolean :is_alias
      t.text :word

      t.timestamps
    end
  end
end
