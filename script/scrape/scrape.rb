#-*- coding: utf-8 -*-
require "#{Rails.root}/app/workers/images_face"

module Scrape
  require "#{Rails.root}/script/scrape/scrape_nico"
  require "#{Rails.root}/script/scrape/scrape_piapro"
  require "#{Rails.root}/script/scrape/scrape_deviant"
  require "#{Rails.root}/script/scrape/scrape_4chan"
  require "#{Rails.root}/script/scrape/scrape_tumblr"
  require "#{Rails.root}/script/scrape/scrape_giphy"
  require "#{Rails.root}/script/scrape/scrape_anipic"

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

  # タグ登録直後の配信用
  # @param [TargetWord] 配信対象であるTargetWordインスタンス
  def self.scrape_target_word(user_id, target_word, logger)
    Scrape::Nico.new(logger).scrape_target_word(user_id, target_word)
    Scrape::Tumblr.new(logger).scrape_target_word(user_id, target_word)
    #Scrape::Twitter.new(logger).scrape_target_word(user_id, target_word)
    Scrape::Anipic.new(logger).scrape_target_word(user_id, target_word)

    # 英名が存在する場合はさらに検索
    # Englishかどうかはscrape_using_api内で判定し、にほんご
    if target_word.person and target_word.person.name_english and not target_word.person.name_english.empty?
      query = target_word.person.name_english
      logger.debug "name_english: #{query}"

      Scrape::Anipic.new(logger).scrape_target_word(user_id, target_word, true)
      Scrape::Tumblr.new(logger).scrape_target_word(user_id, target_word, true)
      Scrape::Giphy.new(logger).scrape_target_word(user_id, target_word)
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

  # TargetWordから、API使用時に用いるクエリを取得する
  # @return [String] APIリクエストのパラメータとして使う文字列（'鹿目まどか'など）
  def self.get_query(target_word)
    return nil if target_word.nil?
    target_word.person ? target_word.person.name : target_word.word
  end

  # TargetWordから、API使用時に用いるクエリを取得する
  # @return [String] APIリクエストのパラメータとして使う文字列（'鹿目まどか'など）
  def self.get_query_en(target_word, key)
    case key
      when 'english' then
        if target_word.person
          query = target_word.person.name_english  # word:'鹿目まどか', person.name_english:'Madoka Kaname'
        elsif target_word.word.ascii_only?
          query = target_word.word                 # word:'Madoka Kaname', person.name_english:nil
        end
      when 'roman' then
        if target_word.person
          query = target_word.person.name_roman    # word:'鹿目まどか', person.name_roman:'Kaname Madoka'
        elsif target_word.word.ascii_only?
          query = target_word.word                 # word:'Madoka Kaname', person.name_english:nil
        end
      else
        query = Scrape.get_query target_word
      end

    query
  end

  def self.get_titles (target_word)
    return nil if target_word.nil?
    target_word.person.titles if target_word.person and target_word.person.titles
  end


  # タグを取得する。DBに既にある場合はそのレコードを返す
  # @param [String]
  def self.get_tag(tag)
    t = Tag.where(name: tag)
    t.empty? ? Tag.new(name: tag) : t.first
  end

  # Tagインスタンスの配列を作成する
  # @param [Array] タグを表す文字列の配列
  # @return [Array] Tagオブジェクトの配列
  def self.get_tags(tags)
    tags.map do |tag|
      t = Tag.where(name: tag)
      t.empty? ? Tag.new(name: tag) : t.first
    end
  end

  def self.remove_4bytes(string)
    return nil if string.nil?
    string.each_char.select{|c| c.bytes.count < 4 }.join('')
  end

end
