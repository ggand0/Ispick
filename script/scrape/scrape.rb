#-*- coding: utf-8 -*-
require "#{Rails.root}/app/workers/images_face"

module Scrape
  require "#{Rails.root}/script/scrape/scrape_nico"
  require "#{Rails.root}/script/scrape/scrape_piapro"
  require "#{Rails.root}/script/scrape/scrape_pixiv"
  require "#{Rails.root}/script/scrape/scrape_deviant"
  require "#{Rails.root}/script/scrape/scrape_futaba"
  require "#{Rails.root}/script/scrape/scrape_2ch"
  require "#{Rails.root}/script/scrape/scrape_4chan"
  require "#{Rails.root}/script/scrape/scrape_twitter"
  require "#{Rails.root}/script/scrape/scrape_tumblr"
  require "#{Rails.root}/script/scrape/scrape_giphy"

  # 全てのTargetWordに基づき画像抽出する
  def self.scrape_all
    TargetWord.all.each do |target_word|
      self.scrape_keyword target_word
    end
    puts 'DONE!!'
  end

  # ユーザが登録している全てのTargetWordに基づき画像抽出する
  # （全てのTargetWordレコードとは必ずしも一致しない）
  def self.scrape_users
    User.all.each do |user|
      user.target_words.each do |target_word|
        self.scrape_keyword target_word if target_word.enabled
      end
    end
    puts 'DONE!!'
  end


  # 定時配信時、タグ検索APIを用いて抽出するサイト用の関数
  # Scrape images from websites which has api. The latter two params are used for testing.
  # @param [Integer] min
  # @param logger [Logger] logger instance to output logs.
  # @param [Boolean] whether it's called for debug or not
  # @param [Boolean] whether it's called for debug or not
  def self.scrape_target_words(module_type, logger, limit=20, interval=60,
    pid_debug=false, sleep_debug=false)
    # 予備時間が十分に取れない程短時間の場合は例外を発生させる
    if interval < 15
      raise Exception.new('the interval argument must be more than 10!')
      return
    end

    # Generate an instance of a default logger
    logger = Logger.new('log/scrape.log') if logger.nil?

    child_module = Object::const_get(module_type)
    reserved_time = 10
    local_interval = (interval-reserved_time) / (TargetWord.count*1.0)

    logger.info '--------------------------------------------------'
    logger.info "Start extracting from #{child_module::ROOT_URL}: time=#{DateTime.now}"
    logger.info "interval=#{interval} local_interval=#{local_interval}"

    # PIDファイルを用いて多重起動を防ぐ
    Scrape.detect_multiple_running(module_type, pid_debug, false)

    # １タグごとにタグ検索APIを用いて画像取得
    TargetWord.all.each do |target_word|
      if target_word.enabled
        begin
          query = Scrape.get_query target_word
          logger.info "query=#{query} time=#{DateTime.now}"

          # パラメータに基づいてAPIリクエストを行い結果を得る
          result = child_module.scrape_using_api(query, limit, true)
          logger.info "scraped: #{result[:scraped]}, duplicates: #{result[:duplicates]}, skipped: #{result[:skipped]}, avg_time: #{result[:avg_time]}"
        rescue => e
          logger.info e
          logger.error "Scraping from #{child_module::ROOT_URL} has failed!"
        end
      end

      sleep(local_interval*60) unless sleep_debug
    end
    logger.info '--------------------------------------------------'
  end

  # タグ登録直後の配信用
  # @param [TargetWord] 配信対象であるTargetWordインスタンス
  def self.scrape_target_word(target_word, logger)
    Scrape::Nico.scrape_target_word(target_word, logger)
    Scrape::Twitter.scrape_target_word(target_word, logger)
    Scrape::Tumblr.scrape_target_word(target_word, logger)

    # 英名が存在する場合はさらに検索
    if target_word.person and not target_word.person.name_english.empty?
      query = target_word.person.name_english
      logger.debug "name_english: #{query}"

      Scrape::Tumblr.scrape_target_word(target_word, logger)
      Scrape::Giphy.scrape_target_word(target_word, logger)
    end
    logger.info 'scrape_target_word DONE!!'
  end

  # Paperclipのattachmentがnilのレコードを探し再度downloadする
  def self.redownload
    images = Image.where(data_file_size: nil)
    puts "number of images with nil data: #{images.count}"

    images.each do |image|
      Resque.enqueue(DownloadImage, image.class.name, image.id, image.src_url)
    end
  end

  # 重複したsrc_urlを持つレコードがDBにあるか調べる
  # @param [String] 確認するsource url.
  def self.is_duplicate(src_url)
    Image.where(src_url: src_url).length > 0
  end

  # TargetWordのレコードから、API使用時に用いるクエリを取得する
  # @return [String] APIリクエストのパラメータとして使う文字列（'鹿目まどか'など）
  def self.get_query(target_word)
    target_word.person ? target_word.person.name : target_word.word
  end

  # PIDファイルを用いて多重起動を防ぐ
  # @param [Boolean] PidFileを使用するかどうか
  # @param [Boolean] デバッグ出力を行うかどうか
  def self.detect_multiple_running(module_type, pid_debug, debug=false)
    unless pid_debug
      if PidFile.running? # PidFileが存在する場合はプロセスを終了する
        logger.info 'Another process is already runnnig. Exit.'
        exit
      end

      # PidFileが存在しない場合、新たにPidFileを作成し、
      # 新たにプロセスが生成されるのを防ぐ
      pid_hash = {
        pidfile: "#{module_type}.pid",
        piddir: "#{Rails.root}/tmp/pids"
      }
      p = PidFile.new(pid_hash)

      # デフォルトでは/tmp以下にPidFileが作成される
      logger.debug 'PidFile DEBUG:'
      logger.debug p.pidfile
      logger.debug p.piddir
      logger.debug p.pid
      logger.debug p.pidpath
    end
  end


  # Imageレコード生成とユーザへの配信を同時に行う
  # @param [Hash] Imageレコードに与える属性のHash
  # @param [Integer] 配信対象のUserレコードのID
  # @param [Integer] 画像抽出の元となったのTargetWordレコードのID
  # @param [Array] 関連するタグ(String)の配列
  # @param [Boolean] validationを行うかどうか
  def self.save_and_deliver(attributes, user_id, target_word_id, tags=[], validation=true)
    image_id = self.save_image(attributes, tags, validation)
    Deliver.deliver_one(user_id, target_word_id, image_id)
  end


  # Imageレコードを新たに生成してDBに保存する
  # @param [Hash] Imageレコードに与える属性のHash
  # @param [Array] 関連するタグ(String)の配列
  # @param [Boolean] validationを行うかどうか
  # @param [Boolean] 大きいサイズの画像かどうか
  # @param [Boolean] ログ出力を行うかどうか
  # @return [Integer] 保存されたImageレコードのID。失敗した場合はnil
  def self.save_image(attributes, logger, tags=[],
    validation=true, large=false, verbose=false)

    # 重複を確認
    if validation and self.is_duplicate(attributes[:src_url])
      logger.info 'Skipping a duplicate image...' if verbose
      return
    end

    # 新規レコードを作成
    begin
      image = Image.new attributes
      tags.each { |tag| image.tags << tag }
    rescue Exception => e
      # URLからImage.dataを設定するのに失敗場合は保存を断念
      logger.error e
      return
    end


    begin
      # 高頻度で失敗し得るのでsave!を使わない（例外は投げない）ようにする
      if image.save(validate: validation)

        # 特徴抽出処理をresqueで非同期的に行う
        if large
          Resque.enqueue(DownloadImageLarge, image.class.name, image.id, attributes[:src_url])
        else
          Resque.enqueue(DownloadImage, image.class.name, image.id, attributes[:src_url])
        end
      else
        logger.info('Image model saving failed. (maybe due to duplication)')
        logger.info 'Image model saving failed. (maybe due to duplication)'
        return
      end
    rescue Exception => e
      logger.error e
      return
    end

    image.id
  end

end
