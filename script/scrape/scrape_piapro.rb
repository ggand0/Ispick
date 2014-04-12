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
      Rails.logger.info('Could not open the page.')
      return false
    end
    html
  end

  # 対象HTMLオブジェクトから画像・文字情報を抽出する
  #def self.get_contents(html, agent, image_data)
  def self.get_contents(page_url, agent, image_data)
    # NokogiriではなくMechanizeを使う
    begin
      page = agent.get(page_url)
    rescue Exception => e
      # ページを開くのに失敗した場合
      puts e
      puts 'PAGE_URL: ' + page_url
      Rails.logger.info('Could not open the page.')
      return
    end
    bookmarks = page.at("span[id='_bookmark_count_span']").content

    # ...style="background:url(http://c1.piapro.jp/xxx.png) no-repeat center;">
    # という文字列からURLを切り取る
    str = page.at("div[class='dtl_works dtl_ill']")
    src_url = str['style'][/\((.*?)\)/] # (...)の中のurlを取り出す
    src_url = src_url.gsub(/[()]/, "")  # ()を除去

    # その他の情報を取得
    title = page.at("h1[class='dtl_title']").content
    caption = page.at("p[class='dtl_cap']").content
    tag_elements = page.at("ul[class='taglist']").css('a')
    tags = tag_elements.map { |tag| Tag.new(name: tag.content) }

    # save_imageに渡すhash作成
    info = {
      title: title,
      caption: caption,
      src_url: src_url,
      favorites: bookmarks
    }
    image_data = image_data.merge(info)
    puts image_data[:src_url]

    # Imageモデル生成＆DB保存
    Scrape::save_image(image_data, tags)
  end

  def self.login()
    agent = Mechanize.new
    agent.ssl_version = 'SSLv3'
    #agent.post('https://piapro.jp/login/',
    #  'text' => CONFIG['piapro_email'],'password' => CONFIG['piapro_password'])
    agent.get('https://piapro.jp/login/')
    form = agent.page.forms[2]
    username_field = form.field_with(name: '_username')
    username_field.value = CONFIG['piapro_email']
    password_field = form.field_with(name: '_password')
    password_field.value = CONFIG['piapro_password']
    result = form.submit

    agent
  end

  def self.get_stats

  end

  # ピアプロは抽出しやすい
  def self.scrape()
    puts 'Extracting : ' + ROOT_URL

    # オフィシャルカテゴリに属するイラストの新着を見る
    base_url = 'http://piapro.jp/illust/?categoryId=3'
    html = Nokogiri::HTML(open(base_url))
    agent = self.login()

    # class属性名が「i_image」であるタグに注目
    html.css("div[class='i_main']").each do |main|
      # JSTに変更してからUTCへ
      item = main.css("a[class='i_image']").first
      time = main.css("p[class='post']").first.content
      posted_at = DateTime.parse(time).change(offset: '+0900').utc
      image_data = {
        page_url: URI.join(ROOT_URL, item['href']).to_s,
        posted_at: posted_at,
        site_name: 'piapro'
      }

      html = self.get_illust_html(item)
      #self.get_contents(html, agent, image_data) if html
      self.get_contents(image_data[:page_url], agent, image_data) if html
    end
  end

end