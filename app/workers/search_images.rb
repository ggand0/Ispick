#-*- coding: utf-8 -*-
class SearchImages
  # Woeker起動時に指定するQUEUE名
  @queue = :search_images

  # 画像をcopyする
  def self.perform(target_word_id)
    t0 = Time.now
    target_word = TargetWord.find(target_word_id)
    #query = target_word.person ? target_word.person.name : target_word.word
    Scrape.scrape_keyword(target_word)
    #Deliver.deliver_keyword(target_word.user_id, target_word.id)

    puts 'TIME: ' + (Time.now - t0).to_s
    puts 'SEARCH IMAGES DONE!'
  end
end