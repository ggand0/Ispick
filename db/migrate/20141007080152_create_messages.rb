class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :name
      t.string :email
      t.text :subject
      t.text :body

      t.timestamps
    end
  end
end
