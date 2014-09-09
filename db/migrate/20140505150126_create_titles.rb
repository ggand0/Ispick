class CreateTitles < ActiveRecord::Migration
  def change
    create_table :titles do |t|
      t.text :name          # E.g. '魔法少女まどか☆マギカ'
      t.text :name_roman    # E.g. 'Mahou Shoujo Madoka Magika'
      t.text :name_english  # E.g. 'Puella Magi Madoka Magica'

      t.timestamps
    end
  end
end
