class CreateTitles < ActiveRecord::Migration
  def change
    create_table :titles do |t|
      t.text :name          # '魔法少女まどか☆マギカ'
      t.text :name_english  # 'Puella Magi Madoka Magica'

      t.timestamps
    end
  end
end
