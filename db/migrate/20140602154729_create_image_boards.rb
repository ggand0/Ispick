class CreateImageBoards < ActiveRecord::Migration
  def change
    create_table :image_boards do |t|
      t.string :name
      t.integer :user_id

      t.timestamps
    end
  end
end
