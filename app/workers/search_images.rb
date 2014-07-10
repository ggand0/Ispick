#-*- coding: utf-8 -*-
class SearchImages
  extend Resque::Plugins::Logger
  @queue = :search_images

  # タグ登録直後に実行されるjob
  # 画像抽出と配信を同時に行う
  def self.perform(user_id, target_word_id)
    start = Time.now
    target_word = TargetWord.find(target_word_id)
    logger.info '--------------------------------------------------'
    logger.info "Starting: target_word=#{target_word_id}, time=#{DateTime.now}"

    # 先に、既にDB内に存在するレコードから配信する
    #Deliver.deliver_keyword(target_word.user_id, target_word.id, logger)
    Deliver.deliver_keyword(user_id, target_word.id, logger)

    # 続いて少量のリクエストを各サイトに送り結果を取得する
    Scrape.scrape_target_word(user_id, target_word, logger)

    logger.info "Finished: elapsed_time=#{(Time.now - start).to_s}"
    logger.info 'SEARCH IMAGES DONE!'
    logger.info '--------------------------------------------------'
  end
end