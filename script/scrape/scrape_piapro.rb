# coding: utf-8
require 'open-uri'

module Scrape::Piapro
  ROOT_URL = 'http://piapro.jp/'

  # 単一イラストを表示するページのHTMLオブジェクトを返す
  def self.get_illust_html(item)
    # リンク先がサイト内URLで表されているので、ROOT_URLと組み合わせてURL生成しアクセス
    begin
      page_url = item['href']
      root_img_url = URI.join(ROOT_URL, page_url).to_s
      html = Nokogiri::HTML(open(root_img_url))
    rescue Exception => e
      Rails.logger.info('Image model saving failed.')
      return false
    end
    html
  end

  # 対象HTMLオブジェクトから画像・文字情報を抽出する
  def self.get_contents(html)
    # ...style="background:url(http://c1.piapro.jp/xxx.png) no-repeat center;">
    # という文字列からURLを切り取る
    str = html.css("div[class='dtl_works dtl_ill']").first
    img_url = str['style'][/\((.*?)\)/] # (...)の中のurlを取り出す
    img_url = img_url.gsub(/[()]/, "")  # ()を除去
    puts img_url

    title = html.css("h1[class='dtl_title']").first.content
    caption = html.css("p[class='dtl_cap']").first.content
    tag_elements = html.css("ul[class='taglist']").css('a')
    tags = tag_elements.map { |tag| Tag.new(name: tag.content) }

    # Imageモデル生成＆DB保存
    Scrape::save_image(title, img_url, caption, tags)
  end

  # ピアプロは抽出しやすい
  def self.scrape()
    puts 'Extracting : ' + ROOT_URL

    # オフィシャルカテゴリに属するイラストの新着を見る
    base_url = 'http://piapro.jp/illust/?categoryId=3'
    html = Nokogiri::HTML(open(base_url))

    # class属性名が「i_image」であるタグに注目
    html.css("a[class='i_image']").each do |item|
      if page = self.get_illust_html(item)
        self.get_contents(page)
      end
    end
  end

end