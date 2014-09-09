class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.boolean :is_alias   # キャラクタのエイリアスを表す語であるかどうか
      t.text :name          # E.g. 'かなめ まどか', 'pink', 'ribon'

      t.timestamps
    end
  end
end
