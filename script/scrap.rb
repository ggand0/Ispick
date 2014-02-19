module Scrap
  require "#{Rails.root}/script/scrap_nico"
  require "#{Rails.root}/script/scrap_piapro"
  require "#{Rails.root}/script/scrap_pixiv"

  def self.scrap_all()
    Scrap::Nico.scrap()
    Scrap::Piapro.scrap()
    Scrap::Pixiv.scrap()
    puts 'DONE!!'
  end
end

# 抽出開始
#Scrap.scrap_all()