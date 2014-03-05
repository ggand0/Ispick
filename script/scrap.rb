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

  # 対象webサイト全てから画像抽出を行う。
  def self.scrap_all()
    Scrap::Nico.scrap()
    Scrap::Piapro.scrap()
    Scrap::Pixiv.scrap()
    Scrap::Deviant.scrap()
    Scrap::Futaba.scrap()
    Scrap::Nichan.scrap()
    Scrap::Fourchan.scrap()
    puts 'DONE!!'
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

    # 高頻度で失敗し得るので例外は投げないようにする
    begin
      if image.save
        # 特徴抽出処理をresqueに投げる
        #Resque.enqueue(ImageFace, image.id)
      else
        Rails.logger.info('Image model saving failed.')
        puts 'Image model saving failed.'
      end
    rescue Exception => e
      puts e
    end

  end
end
