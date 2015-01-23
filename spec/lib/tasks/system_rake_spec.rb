require 'spec_helper'
require 'rake'


describe "util rake tasks" do
  before do
    #allow_any_instance_of(IO).to receive(:puts)
    Ispick::Application.load_tasks
  end

  it "system:update_ranking" do
    # Create impressions to 10 images.
    FactoryGirl.create_list(:impression_user1, 10)
    FactoryGirl.create_list(:impression_user2, 2)
    FactoryGirl.create_list(:impression_user3, 1)
    FactoryGirl.create_list(:image_today, 10)
    Rake::Task['system:update_ranking'].invoke

    expect(DailyImage.count).to eq(1)
    expect(RankingImage.count).to eq(10)
    expect(DailyImage.first.image_id).to eq(RankingImage.first.image_id)
  end
end
