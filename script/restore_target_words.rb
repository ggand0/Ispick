require 'csv'

module Util

  # タグを生成しつつ、Personとの関連も設定する
  def self.restore_target_words(csv_file_path)
    # タグ登録直後の配信によって負荷が掛かるのを避けるためにcallbackをskipする
    TargetWord.skip_callback(:create, :after, :search_keyword)
    CSV.foreach(csv_file_path) do |row|

      # 14/07/19
      # id/word/user_id/last_delivered_at/enabled/created_at/updated_at
      # Restore a TargetWord record
      target_word = TargetWord.create({
        :id => row[0],
        :word => row[1],
        #:user_id => row[2],
        :last_delivered_at => row[3],
      })

      # Restore associations if target_word is saved
      if target_word
        begin
          user = User.find(row[2])
          user.target_words << target_word

          name = row[1].delete(' ')               # e.g. '鹿目 まどか' => '鹿目まどか'
          person = Person.where(name: name)
          target_words.person = person if person

          puts "Restored #{target_word.word}"
        rescue => e
          puts e
          puts "Failed to restore #{target_word.word}"
        end
      end
    end
    TargetWord.set_callback(:create, :after, :search_keyword)
  end

end