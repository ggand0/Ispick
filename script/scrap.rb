#-*- coding: utf-8 -*-
require "#{Rails.root}/app/workers/images_face"

module Scrap
  require "#{Rails.root}/script/scrap_nico"
  require "#{Rails.root}/script/scrap_piapro"
  require "#{Rails.root}/script/scrap_pixiv"
  require "#{Rails.root}/script/scrap_deviant"
  require "#{Rails.root}/script/scrap_futaba"
  require "#{Rails.root}/script/scrap_2ch"
  require "#{Rails.root}/script/scrap_4chan"
  require "#{Rails.root}/script/scrap_twitter"

  # 対象webサイト全てから画像抽出を行う。
  def self.scrap_all()
    #Scrap::Nico.scrap()
    #Scrap::Piapro.scrap()
    #Scrap::Pixiv.scrap()
    #Scrap::Deviant.scrap()
    #Scrap::Futaba.scrap()
    #Scrap::Nichan.scrap()
    Scrap::Fourchan.scrap()
    #Scrap::Twitter.scrap()
    puts 'DONE!!'
  end

  def self.scrape_5min
    Scrap::Nico.scrap()
    Scrap::Futaba.scrap()
  end

  def self.scrape_15min()
    Scrap::Piapro.scrap()
    Scrap::Nichan.scrap()
    Scrap::Twitter.scrap()
  end

  def self.scrape_60min()
    Scrap::Pixiv.scrap()
    Scrap::Deviant.scrap()
    Scrap::Fourchan.scrap()
    puts 'DONE!!'
  end

  # 重複したsrc_urlを持つレコードがDBにあるか調べる
  def self.is_duplicate(src_url)
    Image.where(src_url: src_url).length > 0
  end

  # Imageモデル生成＆DB保存
  def self.save_image(title, src_url, caption='')
    begin
      image = Image.new(title: title, src_url: src_url, caption: caption)
      image.image_from_url src_url
    rescue Exception => e
      puts e
      # 失敗したら諦める
      return
    end

    begin
      # 高頻度で失敗し得るので例外は投げないようにする
      if image.save
        # 特徴抽出処理をresqueに投げる
        Resque.enqueue(ImageFace, image.id)
      else
        Rails.logger.info('Image model saving failed.')
        puts 'Image model saving failed.'
      end
    rescue Exception => e
      puts e
    end

  end
end
