require 'spec_helper'

# Deleting tasks
describe "scrape:reset" do
  # 諸々の初期化。gemの仕様的にこれ以上DRYにできない
  before do
    IO.any_instance.stub(:puts)
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  # 全てのImageを削除すること
  it "delete all images" do
    FactoryGirl.create_list(:image, 2)
    subject.invoke
    Image.count.should eq(0)
  end
end

describe "scrape:delete_old" do
  before do
    IO.any_instance.stub(:puts)
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "deletes old records" do
    # 2013/12/31 to 2014/01/09
    FactoryGirl.create_list(:image, 10)
    DateTime.stub(:now).and_return(Time.mktime 2014, 1, 10)

    subject.invoke
    Image.count.should eq(8)
  end
end

describe "scrape:delete_excess" do
  before do
    IO.any_instance.stub(:puts)
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "delete old recoreds to fit the limit" do
    FactoryGirl.create_list(:image, 101)
    subject.invoke 100
    Image.count.should eq(100)
  end
end

# Scraping tasks
describe "scrape:rescrape_all" do
  before do
    IO.any_instance.stub(:puts)
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "should call valid methods" do
    Image.stub(:delete_all).and_return
    Image.should_receive(:delete_all)
    Scrape.stub(:scrape_all).and_return
    Scrape.should_receive(:scrape_all)
    Rake::Task['feature:face_images'].should_receive(:invoke)

    subject.invoke
  end
end

describe "scrape:images" do
  before do
    IO.any_instance.stub(:puts)
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "should call valid methods" do
    Scrape.stub(:scrape_all).and_return
    Scrape.should_receive(:scrape_all)
    subject.invoke
  end
end

# Misc tasks
describe "scrape:min5" do
  before do
    IO.any_instance.stub(:puts)
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "should call a valid method" do
    Scrape.stub(:scrape_5min).and_return
    Scrape.should_receive(:scrape_5min)
    subject.invoke
  end
end
describe "scrape:min15" do
  before do
    IO.any_instance.stub(:puts)
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }
  it "should call a valid method" do
    Scrape.stub(:scrape_15min).and_return
    Scrape.should_receive(:scrape_15min)
    subject.invoke
  end
end
describe "scrape:min30" do
  before do
    IO.any_instance.stub(:puts)
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }
  it "should call a valid method" do
    Scrape.stub(:scrape_30min).and_return
    Scrape.should_receive(:scrape_30min)
    subject.invoke
  end
end
describe "scrape:min60" do
  before do
    IO.any_instance.stub(:puts)
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }
  it "should call a valid method" do
    Scrape.stub(:scrape_60min).and_return
    Scrape.should_receive(:scrape_60min)
    subject.invoke
  end
end