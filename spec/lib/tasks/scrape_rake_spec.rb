require 'spec_helper'

describe 'scrape:delete_old' do
  before do
    # コンソールに出力しないようにしておく
    IO.any_instance.stub(:puts)
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it 'deletes old records' do
    # 1.day.ago to 100.day.ago
    FactoryGirl.create_list(:image, 100)
    subject.invoke
    Image.count.should eq(6)
  end
end

describe 'scrape:delete_excess' do
  before do
    # コンソールに出力しないようにしておく
    IO.any_instance.stub(:puts)
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it 'delete old recoreds to fit the limit' do
    FactoryGirl.create_list(:image, 101)
    subject.invoke 100
    Image.count.should eq(100)
  end
end