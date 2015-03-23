require 'spec_helper'


describe "scrape rake tasks" do
  before do
    allow_any_instance_of(IO).to receive(:puts)
    Ispick::Application.load_tasks
  end


  # ================
  #  Deleting tasks
  # ================
  describe "scrape:delete_old" do
    it "deletes old records" do
      # images that are created from 2013/12/31 to 2014/01/09
      FactoryGirl.create_list(:image, 10)
      allow(DateTime).to receive(:now).and_return(Time.mktime 2014, 1, 10)

      # This line seems to run multiple times.
      # TODO: Make sure it only runs once
      Rake::Task['scrape:delete_old'].invoke
      puts 'test'
      expect(Image.count).to eq(8)
    end
  end

  describe "scrape:delete_excess" do
    it "delete old recoreds to fit the limit" do
      FactoryGirl.create_list(:image_min, 11)
      Rake::Task['scrape:delete_excess'].invoke 10
      expect(Image.count).to eq(10)
    end

    it "set limit to 10000 when no args given" do
      FactoryGirl.create_list(:image_min, 11)
      Rake::Task['scrape:delete_excess'].invoke
      expect(Image.count).to eq(11)
    end
  end

  describe "scrape:delete_excess_image_files" do
    it "delete old recoreds to fit the limit" do
      FactoryGirl.create_list(:image_file, 3)
      Rake::Task['scrape:delete_excess_image_files'].invoke 2
      expect(Image.last.data.url).to eq(Image.get_default_url)
    end
  end

  # ================
  #  Scraping tasks
  # ================
  describe "scrape:all" do
    it "should call valid methods" do
      allow(Scrape).to receive(:scrape_all).and_return nil
      expect(Scrape).to receive(:scrape_all)
      Rake::Task['scrape:all'].invoke
    end
  end

  describe "scrape:keyword" do
    it "should call valid methods" do
      allow(Scrape).to receive(:scrape_keyword).and_return nil
      expect(Scrape).to receive(:scrape_keyword)
      Rake::Task['scrape:keyword'].invoke
    end
  end

end