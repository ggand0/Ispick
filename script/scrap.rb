module Scrap
  require "#{Rails.root}/script/scrap_nico"
  require "#{Rails.root}/script/scrap_piapro"
  require "#{Rails.root}/script/scrap_pixiv"
  require "#{Rails.root}/script/scrap_deviant"

  def self.scrap_all()
    #Scrap::Nico.scrap()
    #Scrap::Piapro.scrap()
    #Scrap::Pixiv.scrap()
    Scrap::Deviant.scrap()
    puts 'DONE!!'
  end
end