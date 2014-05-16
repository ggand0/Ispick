#-*- coding: utf-8 -*-
class SearchImages
  # Woeker起動時に指定するQUEUE名
  @queue = :search_images

  # タグ登録直後に実行されるjob
  # 画像抽出と配信を同時に行う
  def self.perform(target_word_id)
    start = Time.now
    target_word = TargetWord.find(target_word_id)
    #query = target_word.person ? target_word.person.name : target_word.word
    #Scrape.scrape_keyword query
    Scrape.scrape_keyword target_word
    Deliver.deliver_keyword target_word.user_id, target_word.id

    puts 'TIME: ' + (Time.now - start).to_s
    puts 'SEARCH IMAGES DONE!'
  end
end