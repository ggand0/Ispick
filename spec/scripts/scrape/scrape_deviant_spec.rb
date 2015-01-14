require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"

describe Scrape::Deviant do
  let(:valid_attributes) { FactoryGirl.attributes_for(:image_url) }
  before do
    allow_any_instance_of(IO).to receive(:puts)             # Surpress console outputs
    allow(Resque).to receive(:enqueue).and_return nil       # Prevent Resque.enqueue method from running
    @client = Scrape::Deviant.new(nil, 1)
  end


  describe "is_adult method" do
    # A debug url for a mature(adult) content
    # page = 'http://ecchi-enzo.deviantart.com/art/Top-Heavy-ft-Sui-Feng-FREE-435076127'

    it "returns true with mature content" do
      url = 'http://ugly-ink.deviantart.com/art/HAPPY-HALLOWEEN-266750603'
      html = Nokogiri::HTML(open(url))
      expect(Scrape::Deviant.is_adult(html)).to eq(true)
    end

    it "returns false with non-mature contents" do
      url = 'http://www.deviantart.com/art/Crossing-4-437129901'
      html = Nokogiri::HTML(open(url))
      expect(Scrape::Deviant.is_adult(html)).to eq(false)
    end
  end

  describe "get_contents method" do
    before do
      @image_data = {
        title: 'test',
        page_url: 'http://www.deviantart.com/art/Crossing-4-437129901'
      }
      @html = Nokogiri::HTML(open(@image_data[:page_url]))
    end

    it "create an image model from an image source" do
      allow(@client).to receive(:is_adult).and_return(false)
      count = Image.count

      @client.get_contents(@image_data, @html)
      expect(Image.count).to eq(count+1)
    end

    it "writes to log when it fails to open the image page" do
      expect(@client.logger).to receive(:info)#.with('Image model saving failed.')
      expect(@client).not_to receive(:save_image)

      url = 'not_existed_url'
      @client.get_contents({title: 'test', src_url: url}, @html)
    end
  end

  describe "scrape method" do
    it "calls get_data method exactly 1 time when @limit is 1" do
      #allow(@client).to receive(:get_contents).and_return nil
      allow(@client).to receive(:get_data).and_return nil
      expect(@client).to receive(:get_data).at_least(1).times

      @client.scrape()
    end

    it "does NOT create an image record from a mature image" do
      allow(Scrape::Deviant).to receive(:is_adult).and_return(true)
      count = Image.count

      @client.scrape
      expect(Image.count).to eq(count)
    end
  end

  describe "get_data method" do
    it "returns valid hash that contains image's attributes" do
      xml = Nokogiri::XML(open(Scrape::Deviant::ROOT_URL))
      item = xml.css('item')[0]

      result = @client.get_data(item)
      expect(result).to be_a(Hash)

      # Note that keys are symbols, not strings
      expect(result.has_key? :src_url).to eq(true)
      expect(result.has_key? :posted_at).to eq(true)
      expect(result.has_key? :original_view_count).to eq(true)
    end
  end


  describe "get_stats method" do
    before do
      page_url = 'http://www.deviantart.com/art/Madoka-201395121'
      @html = Nokogiri::HTML(open(page_url))
    end

    it "returns updated stats information" do
      puts result = @client.get_stats(@html)

      expect(result).to be_a(Hash)
      expect(result.has_key?('Views')).to eq(true)
      expect(result.has_key?('Favourites')).to eq(true)
      expect(result.has_key?('Downloads')).to eq(true)
      expect(result.has_key?('Comments')).to eq(true)

      # Based on data on 14/01/15
      expect(result['Views']).to be >= 73129
      expect(result['Favourites']).to be >= 9069
    end
  end

end