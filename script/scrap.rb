require "#{Rails.root}/app/workers/images_face"

module Scrap
  require "#{Rails.root}/script/scrap_nico"
  require "#{Rails.root}/script/scrap_piapro"
  require "#{Rails.root}/script/scrap_pixiv"
  require "#{Rails.root}/script/scrap_deviant"

  # 対象webサイト全てから画像抽出を行う。
  def self.scrap_all()
    Scrap::Nico.scrap()
    Scrap::Piapro.scrap()
    Scrap::Pixiv.scrap()
    Scrap::Deviant.scrap()

    puts 'DONE!!'
  end

  # Imageモデル生成＆DB保存
  def self.save_image(title, src_url, caption='')
    image = Image.new(title: title, src_url: src_url, caption: caption)
    image.image_from_url src_url

    if image.save
      # 特徴抽出処理をresqueに投げる
      Resque.enqueue(ImageFace, image.id)
    end

  end
end