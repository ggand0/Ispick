
# coding: utf-8
require 'open-uri'
require "#{Rails.root}/script/pixiv"
#require "#{Rails.root}/script/pixiv/client"

=begin
id = 'ispic6@gmail.com'
pass = 'ybe9f8n3bp'
#pixiv = Pixiv.new(id, pass)
#puts pixiv
pixiv = Pixiv.client(id, pass) {|agent|
  agent.user_agent_alias = 'Mac Safari'
}

illust_id = 123456
illust = pixiv.illust(illust_id)
puts illust.url# => http://www.pixiv.net/member_illust.php?mode=medium&illust_id=123456
=end
#url = "http://spapi.pixiv.net/iphone/search.php?s_mode=s_tag&word=%E3%83%9E%E3%83%8A%E3%82%8A%E3%81%A4&PHPSESSID=0"
url = "http://spapi.pixiv.net/iphone/search.php?s_mode=s_tag&word=%E3%81%BE%E3%81%A9%E3%81%8B%E3%82%8F%E3%81%84%E3%81%84&PHPSESSID=0"

require 'net/http'
require 'uri'

img_urls = []
uri = URI.parse(url)
result = Net::HTTP.get(uri)
lines = result.split("\n")
#puts lines[0].split(",")
#puts lines[0]

# index=0がイラストIDらしい
# i=3:title, i=5:author, i=8:datetime, i=9 tags(スペース区切り), i=18 caption
# i=6: thumbnail
for row in lines
  items = row.split(",")
  #puts items
  #break

  illust_id = items[0]
  illust_id = illust_id.gsub(/[^0-9A-Za-z]/, '')# ""除外
  title = items[3].force_encoding("UTF-8")
  caption = items[18].force_encoding("UTF-8")
  thumbnail = items[6].force_encoding("UTF-8")
  thumbnail = thumbnail.gsub("\"", '')

  #img_url = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id="+illust_id
  img_url = thumbnail
  puts img_url

  image = Image.new(title: title.encode("UTF-8"), caption: caption)
  image.image_from_url img_url
  image.save!
end
#puts items


=begin
BW::HTTP.get(url) do |response|
  if response.ok?
    @feed = response.body.to_str
    lines = @feed.split("\n")
    for row in lines
      @items << row.split(",")
    end
    puts @items
  else
    puts response.error_message
  end
end
=end


=begin
require 'net/http'
require 'uri'
#uri = URI.parse("www.pixiv.net/login.php?mode=login&pixiv_id=#{id}&pass=#{pass}&skip=0")
uri = URI.parse("www.pixiv.net/login.php?mode=login&pixiv_id=ispic6@gmail.com&pass=ybe9f8n3bp&skip=0")
puts Net::HTTP.get(uri)
=end
