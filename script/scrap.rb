module Scrap
  require "#{Rails.root}/script/scrap_nico"
  require "#{Rails.root}/script/scrap_piapro"
  require "#{Rails.root}/script/scrap_pixiv"
  require "#{Rails.root}/script/scrap_deviant"

  # 対象webサイト全てから画像抽出を行う。
  def self.scrap_all()
    #Scrap::Nico.scrap()
    Scrap::Piapro.scrap()
    Scrap::Pixiv.scrap()
    Scrap::Deviant.scrap()

    puts 'DONE!!'
  end

  # Imageモデル生成＆DB保存
  def self.save_image(title, src_url, caption='')
    image = Image.new(title: title, src_url: src_url, caption: caption)
    image.image_from_url src_url

    duplicate = Image.where(src_url: src_url)
    if duplicate.count == 0
      image.save!
    end
  end
end