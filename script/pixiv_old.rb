# coding: utf-8
# http://gunex.blog57.fc2.com/blog-entry-107.html
require 'rubygems'
require 'mechanize'
require 'uri'

class Mechanize
  class Page
    def utf8
      b = body
      b.force_encoding("UTF-8") if b
      b
    end
  end
end

class Object
  def self.lazy_attr_reader(bind, *names)
    names.each do |name|
      define_method name do
        send bind
        instance_variable_get :"@#{name}"
      end
    end
  end
end

class Pixiv
  attr_reader :agent, :bookmark_new_illust

  def initialize(pixiv_id, pass)
    @agent = Mechanize.new
    @agent.max_history = 1
    login(pixiv_id, pass)
    @bookmark_new_illust = BookmarkNewIllust.new(self)
  end

  class LoginFailedError < StandardError; end

  def login(pixiv_id, pass)
=begin    
    #form = get('http://www.pixiv.net/index.php').forms.first
    form = get('https://www.secure.pixiv.net/login.php').forms.first
    form.pixiv_id = pixiv_id
    form.pass = pass
    raise LoginFailedError unless @agent.submit(form).utf8 =~ /ログアウト/
=end
  doc = agent.get("http://www.pixiv.net/index.php")
  return if doc && doc.body =~ /logout/
  form = doc.forms_with(action: '/login.php').first
  puts doc.body and raise Error::LoginFailed, 'login form is not available' unless form
  form.pixiv_id = pixiv_id
  form.pass = pass
  doc = agent.submit(form)
  raise Error::LoginFailed unless doc && doc.body =~ /logout/
  #@member_id = member_id_from_mypage(doc)    
  end
  
  def get(url, options={})
    wait_time = options[:sleep] || 1
    puts "get: #{url}, options:#{options}"
    sleep wait_time if wait_time
    @agent.get(url, options.fetch(:query, []), options[:refer])
  end
  
  def member_illust_list(id)
    MemberIllustList.new self, id
  end
  def search(word, s_mode)
    Search.new(self, word, s_mode)
  end
  def search_by_tag(word)
    search(word, 's_tag')
  end
  def search_by_title_and_caption(word)
    search(word, 's_tc')
  end
  
  def member_illust(id)
    MemberIllust.new(self, id)
  end
  
  class MemberIllust
    attr_reader :id, :url, :pixiv
    lazy_attr_reader :init_page, :title, :artist, :artist_id, :type, :illust, :manga
    def initialize(pixiv, id)
      @pixiv = pixiv
      @id = id.to_i
      @url = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=#{id}"
      @init_page = false
      @illust = nil
      @manga = nil
    end
    def medium
      @illust.medium if illust?
    end
    def big
      @illust.big if illust?
    end
    
    def each(&b)
      if illust?
        b.call(illust)
      else
        manga.each(&b)
      end
    end
    
    def manga?
      @manga ? true : false
    end
    
    def illust?
      @illust ? true : false
    end
    
  private
    
    lazy_attr_reader :init_page, :manga_urls, :manga_page_url
    
    def init_page
      unless @init_page
        page = @pixiv.get(@url)
        # Get Title and Artist
        page.title =~ /\A「(.+)」\/「(.+)」の(イラスト|漫画) \[pixiv\]\z/
        @title, @artist, @type = $1, $2, $3
        page.utf8 =~ %r[<a href="/member.php\?id=(\d+)" class="avatar_m" [^>]*>]
        @artist_id = $1
        if @type == "イラスト"
          # Get Medium Size URL
          @illust = Illust.new(self, page)
        else
          # Manga
          @manga = Manga.new(self, page)
        end
        @init_page = true
      end
    end
    
    class Picture
      def self.delegate(*names)
        names.each do |name|
          define_method name do |*args, &b|
            @member_illust.send(name, *args, &b)
          end
        end
      end
      
      def initialize(member_illust)
        @member_illust = member_illust
      end
      
      delegate :pixiv, :id, :title, :artist, :artist_id
    end
    
    class Illust < Picture
      def initialize(member_illust, page)
        super(member_illust)
        page.utf8 =~ /"(http:\/\/.+\.pixiv\.net\/img\/.+\/\d+_m(\..{3})(?:\?\d+)?)"/
        @medium_url = $1
        @ext = $2
        
        @big_page_url = "http://www.pixiv.net/member_illust.php?mode=big&illust_id=#{id}"
        @init_big = false
      end
      
      attr_reader :medium_url, :ext, :big_page_url
      lazy_attr_reader :init_big, :url, :big_url
      
      def data
        big
      end
      
      def medium
        pixiv.get(medium_url, refer: @member_illust.url).body
      end
      
      def big
        pixiv.get(big_url, refer: big_page_url, sleep: nil).body
      end
      
      def filename
        "#{id}_#{title}#{ext}"
      end
      
    private
      
      def init_big
        unless @init_big
          # Get Big Size URL
          bigpage = pixiv.get(big_page_url, refer: @member_illust.url)
          bigpage.utf8 =~ %r[<img src="(http://img\d+\.pixiv\.net/img/[^/]+/\d+\..{3}(?:\?\d+)?)" border="0">]
          @url = @big_url = $1
          @init_big = true
        end
      end
    end
    
    class Manga
      include Enumerable
      
      NUMBER_OF_PAGE_PER_SCREEN = 50
      def initialize(member_illust, page)
        @member_illust = member_illust
        @id = member_illust.id
        @url = "http://www.pixiv.net/member_illust.php?mode=manga&illust_id=#{id}&type=scroll"
        @pages = nil
      end
      
      def pixiv
        @member_illust.pixiv
      end
      
      attr_reader :id, :member_illust, :illust_url, :url
      
      def init_manga
        unless @pages
          @pages = []
          loop do
            i = 0
            if @pages.empty?
              manga_page = pixiv.get(scroll_url(@pages.size), refer: member_illust.url)
            else
              manga_page = pixiv.get(scroll_url(@pages.size), refer: scroll_url(@pages.size - 1))
            end
            manga_page.utf8.scan(%r[<a href=".*"><img src="(http://img\d+\.pixiv\.net/img/[^/]+/\d+_p(\d+)(\..{3})(?:\?\d+)?)"></a>]) do |m|
              @pages << Page.new(self, m[1].to_i, m[0], m[2])
              i += 1
            end
            break unless i == NUMBER_OF_PAGE_PER_SCREEN
          end
        end
      end
      
      def scroll_url(idx)
        scroll_page = (idx / NUMBER_OF_PAGE_PER_SCREEN) + 1
        "#{url}&p=#{scroll_page}"
      end
      
      def [](idx)
        init_manga
        @pages[idx]
      end
      
      def each(&b)
        init_manga
        @pages.each(&b)
      end
      
      class Page < Picture
        def initialize(manga, index, url, ext)
          super(manga.member_illust)
          @manga = manga
          @index = index
          @url = url
          @ext = ext
        end
        
        attr_reader :index, :url, :ext
        
        def data
          pixiv.get(url, refer: @manga.scroll_url(index), sleep: nil).body
        end
        
        def filename
          "#{id}_#{title}_p#{index}#{ext}"
        end
      end
    end
  end
  class MemberIllustListBase
    include Enumerable
    
    NUMBER_OF_ILLUST_PER_PAGE = 20
    def initialize(pixiv)
      @pixiv = pixiv
      @member_illusts = []
      @reach_last = false
    end
    
    attr_reader :pixiv
    def [](idx)
      if not @reach_last and idx >= @member_illusts.size
        start_p = @member_illusts.size / NUMBER_OF_ILLUST_PER_PAGE + 1
        goal_p = idx / NUMBER_OF_ILLUST_PER_PAGE + 1
        for pn in start_p..goal_p
          url = generate_url(pn)
          page = pixiv.get(url)
          i = 0
          page.links.each do |link|
            if link.href =~ /member_illust\.php\?mode=medium&illust_id=(\d+)/
              member_illust = MemberIllust.new(pixiv, $1)
              @member_illusts << member_illust
              i += 1
            end
          end
          unless i == NUMBER_OF_ILLUST_PER_PAGE
            @reach_last = true
            break
          end
        end
      end
      return @member_illusts[idx]
    end
    def each(&b)
      if b
        i = 0
        while c = self[i]
          b.(c)
          i += 1
        end
        self
      else
        enum_for :each
      end
    end
  end
  class BookmarkNewIllust < MemberIllustListBase
    def generate_url(pn)
      "http://www.pixiv.net/bookmark_new_illust.php?mode=new&p=#{pn}"
    end
  end
  
  class MemberIllustList < MemberIllustListBase
    def initialize(pixiv, member_id)
      super(pixiv)
      @member_id = member_id
    end
    
    attr_reader :member_id
    def generate_url(pn)
      "http://www.pixiv.net/member_illust.php?id=#{member_id}&p=#{pn}"
    end
  end
  
  class Search < MemberIllustListBase
    def initialize(pixiv, word, s_mode)
      super(pixiv)
      @word = word
      @s_mode = s_mode
    end
    def generate_url(pn)
      "http://www.pixiv.net/search.php?word=#{URI.encode_www_form_component(@word)}&s_mode=#{@s_mode}&p=#{pn}"
    end
  end
end