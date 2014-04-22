require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/scrape_tumblr"

describe Scrape::Tumblr do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    IO.any_instance.stub(:puts)       # コンソールに出力しないようにしておく
    Resque.stub(:enqueue).and_return  # resqueにenqueueしないように
    @client = Scrape::Tumblr.get_client()
  end

  describe "scrape method" do
    it "calls scrape_with_keyword function" do
      FactoryGirl.create(:person_madoka)
      Scrape::Tumblr.should_receive(:scrape_with_keyword)
      Scrape::Tumblr.scrape()
    end
    it "does not call scrape_with_keyword function when targetable is NOT enabled" do
      FactoryGirl.create(:target_word_not_enabled)
      Scrape::Tumblr.stub(:scrape_with_keyword).and_return
      Scrape::Tumblr.should_not_receive(:scrape_with_keyword)

      Scrape::Tumblr.scrape()
    end
    it "skips keywords with nil or empty value" do
      nil_word = TargetWord.new
      nil_word.save!
      Scrape::Tumblr.stub(:scrape_with_keyword).and_return
      Scrape::Tumblr.should_not_receive(:scrape_with_keyword)

      Scrape::Tumblr.scrape()
    end
  end

  describe "scrape_with_keyword function" do
    it "calls proper functions" do
      Scrape::Tumblr.should_receive(:get_client)
      Scrape::Tumblr.should_receive(:get_images)
      Scrape::Tumblr.should_receive(:save)
      Scrape::Tumblr.stub(:get_images).and_return({})
      Scrape::Tumblr.stub(:save).and_return()

      Scrape::Tumblr.scrape_with_keyword('madoka', 5)
    end
  end

  describe "get_stats function" do
    it "returns a hash with favorites value" do
      page_url = 'http://zan66.tumblr.com/post/74921850483'
      stats = Scrape::Tumblr.get_stats(page_url)
      expect(stats).to be_a(Hash)
    end
  end

  describe "get_client function" do
    it "returns tumblr client" do
      client = Scrape::Tumblr.get_client
      client.class.should eq(Tumblr::Client)
    end
  end

  describe "get_favorites function" do
    it "returns favorites count of the post" do
      page_url = 'http://senshi.org/post/82331944259/miku-x-cat-by-kenji'
      html = Nokogiri::HTML(open(page_url))
      result = Scrape::Tumblr.get_favorites(html)

      puts result
      expect(result).not_to eql(nil)
    end
  end

  describe "get_contents function" do
    it "returns image_data hash" do
      url = 'http://realotakuman.tumblr.com/post/80263089672/pixiv'
      html = Nokogiri::HTML(open(url))
      image = {
        "blog_name"=>"realotakuman",
        "id"=>80263089672,
        "post_url"=>"http://realotakuman.tumblr.com/post/80263089672/pixiv",
        "date"=>"2014-03-21 14:54:12 GMT",
        "tags"=>["アナログ", "VOICEROID+", "結月ゆかり", "弦巻マキ"],
        "note_count"=>3,
        "caption"=>"blah blah",
        "photos"=>[{"original_size"=>{
          "width"=>697,
          "height"=>981,
          "url"=>"http://37.media.tumblr.com/9cbde1a610fd826c87600caa3372e176/tumblr_n2sk2cFwOB1qdwsovo1_1280.jpg"
          }}]
      }

      image_data = Scrape::Tumblr.get_contents(html, image)
      expect(image_data).to be_a(Hash)
    end
  end

  describe "get_images function" do
    it "returns a proper image_data array" do
      Tumblr::Client.any_instance.stub(:tagged).and_return([{
        'post_url' => 'http://realotakuman.tumblr.com/post/80263089672/pixiv'
      }])
      Tumblr::Client.any_instance.should_receive(:tagged)
      Scrape::Tumblr.stub(:get_contents).and_return(
        { data: { page_url: 'blog post url'}, tags: 'a tag' }
      )
      Scrape::Tumblr.should_receive(:get_contents)

      image_data = Scrape::Tumblr.get_images(@client, 'madoka', 1)
      expect(image_data).to be_an(Array)
    end
  end

  describe "save function" do
    it "save to database properly" do
      image_data = { data: {src_url: 'blah'}, tags: 'blah' }
      Scrape.stub(:save_image).and_return
      Scrape.stub(:is_duplicate).and_return(false)

      Scrape::Tumblr.save([image_data])
    end
  end

end