require 'spec_helper'

# Deleting tasks
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
    Resque.stub(:enqueue).and_return
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "delete old recoreds to fit the limit" do
    FactoryGirl.create_list(:image, 11)
    subject.invoke 10
    Image.count.should eq(10)
  end

  it "set limit to 10000 when no args given" do
    FactoryGirl.create_list(:image, 11)
    subject.invoke
    Image.count.should eq(11)
  end
end


# Scraping tasks
describe "scrape:all" do
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "should call valid methods" do
    Scrape.stub(:scrape_all).and_return
    Scrape.should_receive(:scrape_all)
    subject.invoke
  end
end

describe "scrape:keyword" do
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "should call valid methods" do
    Scrape.stub(:scrape_keyword).and_return
    Scrape.should_receive(:scrape_keyword)
    subject.invoke
  end
end



# Misc tasks
describe "scrape:min5" do
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return
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
    Resque.stub(:enqueue).and_return
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
    Resque.stub(:enqueue).and_return
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
    Resque.stub(:enqueue).and_return
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }
  it "should call a valid method" do
    Scrape.stub(:scrape_60min).and_return
    Scrape.should_receive(:scrape_60min)
    subject.invoke
  end
end