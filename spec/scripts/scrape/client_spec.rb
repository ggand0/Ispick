require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/client"

describe Scrape::Client do
  before do
    IO.any_instance.stub(:puts)             # コンソールに出力しないようにしておく
    Resque.stub(:enqueue).and_return nil    # resqueにenqueueしないように
    @client = Scrape::Client.new
    #Rails.stub_chain(:logger, :debug).and_return(logger_mock)
    @logger = Logger.new('log/scrape_cron.log')
  end

  describe "scrape_target_words method" do
    it "skips keywords with nil or empty value" do
      nil_word = TargetWord.new
      nil_word.save!
      @client.pid_debug = true
      @client.sleep_debug= true

      @client.stub(:scrape_using_api).and_return nil
      @client.stub(:sleep).and_return nil
      @client.should_not_receive(:scrape_using_api)

      @client.scrape_target_words('', 60)

      @client.pid_debug = false
      @client.sleep_debug = false
    end

    it "sleeps with right interval after each scraping" do
      FactoryGirl.create_list(:target_word, 5)  # = 5 TargetWords as all
      puts TargetWord.count
      @client.pid_debug = true
      @client.should_receive(:sleep).with(10*60)      # (60-10) / 5*1.0
      @client.stub(:sleep).and_return nil

      @client.scrape_target_words('', 60)

      # Set it false for the next example
      @client.pid_debug = false
    end

    it "raise error when it gets improper argument" do
      FactoryGirl.create(:person_madoka)
      expect { @client.scrape_target_words('', 14) }.to raise_error(Exception)
    end

    it "exit if another process is running" do
      PidFile.stub(:running?).and_return(true)
      @client.stub(:sleep).and_return nil

      expect {
        @client.scrape_target_words('', 15)
      }.to raise_error(SystemExit)
    end
  end


  describe "save_image method" do
    before do
      @target_word = FactoryGirl.create(:target_word)
    end

    describe "with valid attributes" do
      it "creates a new Image record" do
        Image.any_instance.stub(:image_from_url).and_return nil
        count = Image.count

        id = Scrape::Client.save_image({ title: 'title', src_url: 'src_url' }, @logger, @target_word)
        puts id
        image = Image.find(id)

        Image.count.should eq(count+1)                  # DBに保存されるはず
        expect(@target_word.images.first).to eq(image)  # target_wordに関連づけられるはず
      end

      describe "when the image is not saved" do
        it "should write a log" do
          Image.any_instance.stub(:save).and_return(false)
          Image.any_instance.stub(:image_from_url).and_return nil
          #Rails.logger.should_receive(:info).with('Image model saving failed.')

          Scrape::Client.save_image({ title: 'title', src_url: 'src_url' }, @logger, @target_word)
        end
      end

      describe "when it cannot save the image" do
        it "returns nil" do
          Image.any_instance.stub(:save).and_return(false)

          count = Image.count
          result = Scrape::Client.save_image({ title: 'title', src_url: 'src_url' }, @logger, @target_word)
          expect(result).to eq(nil)
          expect(Image.count).to eq(count)
        end
      end
    end

    describe "with invalid attributes" do
      it "should not save an invalid image when validation param is true" do
        image = FactoryGirl.create(:image)
        count = Image.count
        Scrape::Client.save_image({ title: 'test', src_url: 'test1@example.com' }, @logger, @target_word, [])
        Image.count.should eq(count)
      end

      it "should ignore a duplicate image" do
        image = FactoryGirl.create(:image_min)
        count = Image.count

        Scrape::Client.save_image({ title: 'title', src_url: image.src_url }, @logger, @target_word)
        Image.count.should eq(count)
      end
    end
  end

  describe "generate_jobs method" do
    it "does something" do
      #Resque.unstub(:enqueue)
      #expect(Scrape::Client).to receive(:generate_jobs).with(1, 'goo', false, 1, 'TargetWord', 1)
      #expect(Scrape::Client).to receive(:generate_jobs)#.with(1, 'goo', false, 1, 'TargetWord', 1)

      #Resque.stub(:enqueue)
      expect(Resque).to receive(:enqueue).with(DownloadImage, 1, 'goo', 1, 'TargetWord', 1)#.and_return nil
      #expect(Resque).to receive(:enqueue)#.with(DownloadImage, 1, 'goo')

      puts 'test'
      Scrape::Client.generate_jobs(1, 'goo', false, 1, 'TargetWord', 1)
    end
  end

end