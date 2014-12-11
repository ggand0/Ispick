require 'spec_helper'

# Deleting tasks
=begin
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
    Resque.stub(:enqueue).and_return nil
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "delete old recoreds to fit the limit" do
    FactoryGirl.create_list(:image_min, 11)
    subject.invoke 10
    Image.count.should eq(10)
  end

  it "set limit to 10000 when no args given" do
    FactoryGirl.create_list(:image_min, 11)
    subject.invoke
    Image.count.should eq(11)
  end
end

describe "scrape:delete_excess_image_files" do
  before do
    IO.any_instance.stub(:puts)
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "delete old recoreds to fit the limit" do
    FactoryGirl.create_list(:image_file, 3)
    subject.invoke 2
    expect(Image.last.data.url).to eq(Image.get_default_url)
  end
end




# Scraping tasks
describe "scrape:all" do
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return nil
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "should call valid methods" do
    Scrape.stub(:scrape_all).and_return nil
    Scrape.should_receive(:scrape_all)
    subject.invoke
  end
end

describe "scrape:keyword" do
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return nil
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "should call valid methods" do
    Scrape.stub(:scrape_keyword).and_return nil
    Scrape.should_receive(:scrape_keyword)
    subject.invoke
  end
end
=end
