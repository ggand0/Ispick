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

  # 対象webサイト全てから画像抽出を行う。
  def self.scrape_all()
    Scrape::Nico.scrape()
    #Scrape::Piapro.scrape()
    #Scrape::Deviant.scrape()
    #Scrape::Futaba.scrape()
    #Scrape::Nichan.scrape()
    #Scrape::Fourchan.scrape()
    Scrape::Twitter.scrape()
    Scrape::Tumblr.scrape()
    puts 'DONE!!'
  end

  def self.scrape_keyword(target_word)
    puts query = target_word.person ? target_word.person.name : target_word.word
    Scrape::Nico.scrape_keyword(query)
    #Scrape::Twitter.scrape_keyword(query)
    Scrape::Tumblr.scrape_keyword(query)

    # 英名が存在する場合はさらに検索
    puts "name_english:#{ target_word.person.name_english}"
    #if target_word.person.name_english
    if target_word.person and not target_word.person.name_english.empty?
      query = target_word.person.name_english
      puts "name_english:#{query}"
      Scrape::Tumblr.scrape_keyword(query)
      Scrape::Giphy.scrape_keyword(target_word)
    end
    puts 'DONE!!'
  end

  def self.scrape_5min

    #Scrape::Futaba.scrape()
    puts 'DONE!!'
  end

  def self.scrape_15min()
    #Scrape::Piapro.scrape()
    #Scrape::Nichan.scrape()
    Scrape::Twitter.scrape()

    puts 'DONE!!'
  end

  def self.scrape_30min()
    #Scrape::Fourchan.scrape()
    puts 'DONE!!'
  end

  def self.scrape_60min()
    Scrape::Nico.scrape()
    #Scrape::Pixiv.scrape()
    #Scrape::Deviant.scrape()
    puts 'DONE!!'
  end

  def self.scrape_3h()
    Scrape::Tumblr.scrape()
    puts 'DONE!!'
  end

  # 重複したsrc_urlを持つレコードがDBにあるか調べる
  def self.is_duplicate(src_url)
    Image.where(src_url: src_url).length > 0
  end

  def self.save_and_deliver(attributes, user_id, target_word_id, tags=[], validation=true)
    image_id = self.save_image(attributes, tags, validation)
    Deliver.deliver_one(user_id, target_word_id, image_id)
  end

  # Imageモデル生成＆DB保存
  # @param [Hash] Imageレコードに与える属性のHash
  def self.save_image(attributes, tags=[], validation=true, large=false)
    # 重複を確認
    if validation and self.is_duplicate(attributes[:src_url])
      puts 'Skipping a duplicate image...'
      return false
    end

    # 新規レコードを作成
    begin
      image = Image.new attributes
      #image.image_from_url attributes[:src_url]
      tags.each { |tag| image.tags << tag }
    rescue Exception => e
      # URLからImage.dataを設定するのに失敗したら諦める
      puts e
      return false
    end

    # DBに保存する
    begin
      # 高頻度で失敗し得るのでsave!を使わない（例外は投げない）ようにする
      if image.save(validate: validation)
        # 特徴抽出処理をresqueに投げる
        if large
          Resque.enqueue(DownloadImageLarge, image.class.name, image.id, attributes[:src_url])
        else
          Resque.enqueue(DownloadImage, image.class.name, image.id, attributes[:src_url])
        end
      else
        Rails.logger.info('Image model saving failed. (maybe due to duplication)')
        puts 'Image model saving failed. (maybe due to duplication)'
        return false
      end
    rescue Exception => e
      puts e
      return false
    end
    image.id
  end
end
