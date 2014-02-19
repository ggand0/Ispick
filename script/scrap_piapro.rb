# coding: utf-8
require 'open-uri'

module Scrap::Piapro
  ROOT_URL = 'http://piapro.jp/'

  def self.scrap()
    url = 'http://piapro.jp/illust/?categoryId=3'
    b = Nokogiri::HTML(open(url))
    puts url

    b.css("a[class='i_image']").each do |item|
    	page_url = item['href']
      #puts page_url
    	root_img_url = URI.join(ROOT_URL, page_url).to_s
    	#puts root_img_url

      page = Nokogiri::HTML(open(root_img_url))
      # target : style="background:url(http://c1.piapro.jp/xxx.png) no-repeat center;">
      str = page.css("div[class='dtl_works dtl_ill']").first
      #puts str['style']
      img_url = str['style'][/\((.*?)\)/] # (...)の中のurlを取り出す
      img_url = img_url.gsub(/[()]/, "")  # ()を除去
      #img_url = str['style'].match(/\[(.*?)\]/)
      puts img_url

    	image = Image.new(title: item.text)
    	image.image_from_url img_url
    	image.save!
    end
  end

end