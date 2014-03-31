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

  # 対象webサイト全てから画像抽出を行う。
  def self.scrape_all()
    Scrape::Nico.scrape()
    Scrape::Piapro.scrape()
    Scrape::Pixiv.scrape()
    Scrape::Deviant.scrape()
    Scrape::Futaba.scrape()
    Scrape::Nichan.scrape()
    Scrape::Fourchan.scrape()
    Scrape::Twitter.scrape()
    puts 'DONE!!'
  end

  def self.scrape_5min
    Scrape::Nico.scrape()
    Scrape::Futaba.scrape()
    puts 'DONE!!'
  end

  def self.scrape_15min()
    Scrape::Piapro.scrape()
    Scrape::Nichan.scrape()
    Scrape::Twitter.scrape()
    puts 'DONE!!'
  end

  def self.scrape_30min()
    Scrape::Fourchan.scrape()
    puts 'DONE!!'
  end

  def self.scrape_60min()
    Scrape::Pixiv.scrape()
    Scrape::Deviant.scrape()
    puts 'DONE!!'
  end

  # 重複したsrc_urlを持つレコードがDBにあるか調べる
  def self.is_duplicate(src_url)
    Image.where(src_url: src_url).length > 0
  end

  # Imageモデル生成＆DB保存
  def self.save_image(attributes, tags=[])
    # 重複を確認
    if self.is_duplicate(attributes[:src_url])
      puts 'Skipping a duplicate image...'
      return false
    end

    # 新規レコードを作成
    begin
      image = Image.new attributes
      image.image_from_url attributes[:src_url]
      tags.each { |tag| image.tags << tag }
    rescue Exception => e
      # URLからImage.dataを設定するのに失敗したら諦める
      puts e
      return false
    end

    # DBに保存する
    begin
      # 高頻度で失敗し得るのでsave!を使わない（例外は投げない）ようにする
      if image.save
        # 特徴抽出処理をresqueに投げる
        Resque.enqueue(ImageFace, image.id)
      else
        Rails.logger.info('Image model saving failed.')
        puts 'Image model saving failed.'
        return false
      end
    rescue Exception => e
      puts e
      return false
    end
    true
  end
end
