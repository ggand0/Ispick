require 'spec_helper'
require "#{Rails.root}/script/scrape/scrape"
require "#{Rails.root}/script/scrape/client"

describe Scrape::Client do
  before do
    #IO.any_instance.stub(:puts)
    allow(Resque).to receive(:enqueue).and_return nil
    @client = Scrape::Client.new
    # Uncomment and edit this if you don't want to let it write logs
    #Rails.stub_chain(:logger, :debug).and_return(logger_mock)
    @logger = Logger.new('log/scrape_cron.log')
  end

  describe "scrape_target_words method" do
    it "calls necessary methods" do
      FactoryGirl.create(:target_word)
      expect(@client).to receive(:crawl_target_word)
      expect(@client).to receive(:detect_multiple_running)
      allow(@client).to receive(:sleep).and_return nil
      @client.scrape_target_words('', 60)
    end

    it "skips keywords with nil or empty value" do
      nil_word = TargetWord.new
      nil_word.save!
      @client.pid_debug = true
      @client.sleep_debug= true

      allow(@client).to receive(:scrape_using_api).and_return nil
      allow(@client).to receive(:sleep).and_return nil
      expect(@client).not_to receive(:scrape_using_api)

      @client.scrape_target_words('', 60)

      @client.pid_debug = false
      @client.sleep_debug = false
    end

    it "sleeps with right interval after each scraping" do
      FactoryGirl.create_list(:target_word, 5)  # = 5 TargetWords as all
      puts TargetWord.count
      @client.pid_debug = true
      expect(@client).to receive(:sleep).with(10*60)      # (60-10) / 5*1.0
      allow(@client).to receive(:sleep).and_return nil

      @client.scrape_target_words('', 60)

      # Set it false for the next example
      @client.pid_debug = false
    end

    it "raise error when it gets improper argument" do
      FactoryGirl.create(:person_madoka)
      expect { @client.scrape_target_words('', 14) }.to raise_error(Exception)
    end

    it "exit if another process is running" do
      allow(PidFile).to receive(:running?).and_return(true)
      allow(@client).to receive(:sleep).and_return nil

      expect {
        @client.scrape_target_words('', 15)
      }.to raise_error(SystemExit)
    end
  end


  describe "crawl_target_word method" do
    it "calls sub methods correctly" do
      target_word = FactoryGirl.create(:target_word)
      expect(@client).to receive(:scrape_using_api).exactly(1).times.
        and_return({scraped: 0, duplicates: 0, skipped: 0, avg_time: 0 })

      @client.crawl_target_word('test_module', target_word)
    end
  end



  describe "check_banned method" do
    it "returns false if the image contains no irrelevant words" do
      image = FactoryGirl.create(:image_with_tags)
      expect(Scrape::Client.check_banned(image)).to eq(false)
    end

    it "returns true if its title contain irrelevant words" do
      image = FactoryGirl.create(:image_with_tags)
      image.title = '[R18]'
      expect(Scrape::Client.check_banned(image)).to eq(true)
    end

    it "returns true if its caption contain irrelevant words" do
      image = FactoryGirl.create(:image_with_tags)
      image.caption = '[R18]'
      expect(Scrape::Client.check_banned(image)).to eq(true)
    end
  end


=begin
  describe "check_photo method" do
    it "returns false if the image contains no irrelevant words" do
      image = FactoryGirl.create(:image_with_tags)
      expect(Scrape::Client.check_photo(image)).to eq(false)
    end

    it "returns true if its title contain irrelevant words" do
      image = FactoryGirl.create(:image_with_tags)
      image.title = 'cosplay'
      expect(Scrape::Client.check_photo(image)).to eq(true)
    end

    it "returns true if its caption contain irrelevant words" do
      image = FactoryGirl.create(:image_with_tags)
      image.caption = 'cosplay'
      expect(Scrape::Client.check_photo(image)).to eq(true)
    end
  end


  describe "is_photo method" do
    it "returns true if the tags contain irrelevant words" do
      puts Obscenity.config.inspect
      puts Obscenity.config.blacklist_another

      image = FactoryGirl.create(:image_with_tags)
      image.tags << Tag.new(name: 'cosplay')

      expect(Scrape::Client.is_photo(image.tags)).to eq(true)
    end

    it "returns false if the tags contain r18 words" do
      image = FactoryGirl.create(:image_with_tags)
      image.tags << Tag.new(name: 'r18')

      expect(Scrape::Client.is_photo(image.tags)).to eq(false)
    end
  end
=end

  describe "is_banned method" do
    it "returns true if the tags contain irrelevant words" do
      image = FactoryGirl.create(:image_with_tags)
      image.tags << Tag.new(name: 'R18')

      expect(Scrape::Client.is_banned(image.tags)).to eq(true)
    end

    it "returns true if the tags contain irrelevant words" do
      image = FactoryGirl.create(:image_with_tags)
      image.tags << Tag.new(name: 'cosplay')

      expect(Scrape::Client.is_banned(image.tags)).to eq(true)
    end
  end




  describe "save_image method" do
    before do
      @target_word = FactoryGirl.create(:target_word)
    end

    describe "with valid attributes" do
      it "creates a new Image record" do
        allow_any_instance_of(Image).to receive(:image_from_url).and_return nil
        count = Image.count

        id = Scrape::Client.save_image({ title: 'title', src_url: 'src_url' }, @logger, @target_word)
        puts id
        image = Image.find(id)

        expect(Image.count).to eq(count+1)                  # DBに保存されるはず
        expect(@target_word.images.first).to eq(image)  # target_wordに関連づけられるはず
      end

      describe "when the image is not saved" do
        it "should write a log" do
          allow_any_instance_of(Image).to receive(:save).and_return(false)
          allow_any_instance_of(Image).to receive(:image_from_url).and_return nil
          #Rails.logger.should_receive(:info).with('Image model saving failed.')

          Scrape::Client.save_image({ title: 'title', src_url: 'src_url' }, @logger, @target_word)
        end
      end

      describe "when it cannot save the image" do
        it "returns nil" do
          allow_any_instance_of(Image).to receive(:save).and_return(false)

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
        expect(Image.count).to eq(count)
      end

      it "should ignore a duplicate image" do
        image = FactoryGirl.create(:image_min)
        count = Image.count

        Scrape::Client.save_image({ title: 'title', src_url: image.src_url }, @logger, @target_word)
        expect(Image.count).to eq(count)
      end
    end
  end

  describe "generate_jobs method" do
    it "can be executed without an error" do
      #Resque.unstub(:enqueue)
      #expect(Scrape::Client).to receive(:generate_jobs).with(1, 'goo', false, 1, 'TargetWord', 1)
      #expect(Scrape::Client).to receive(:generate_jobs)#.with(1, 'goo', false, 1, 'TargetWord', 1)

      #Resque.stub(:enqueue)
      expect(Resque).to receive(:enqueue).with(DownloadImage, 1, 'Image', 'goo', 1, 'TargetWord', 1)#.and_return nil
      #expect(Resque).to receive(:enqueue)#.with(DownloadImage, 1, 'goo')

      puts 'test'
      Scrape::Client.generate_jobs(1, 'Image', 'goo', false, 1, 'TargetWord', 1)
    end
  end

  describe "send_error_mail method" do
    it "sends an error email correctly" do
      target_word = FactoryGirl.create(:target_word)
      @client.send_error_mail(Exception.new, 'test', target_word)
      puts ActionMailer::Base.deliveries
    end
  end

end