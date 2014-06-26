require 'spec_helper'

describe "deliver:all" do
  # 諸々の初期化。gemの仕様的にこれ以上DRYにできない
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return nil  # resqueにenqueueしないように
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "calls deliver:user with valid times" do
    # Create two users
    FactoryGirl.create(:user)
    FactoryGirl.create(:user)

    Rake::Task['deliver:user'].stub(:invoke).and_return nil
    Rake::Task['deliver:user'].should_receive(:invoke).exactly(2).times

    subject.invoke
  end
  it "calls Deliver.deliver function indirectly" do
    user1 = FactoryGirl.create(:user)
    user2 = FactoryGirl.create(:user)
    Deliver.stub(:deliver).and_return nil
    #Rake::Task['deliver:user'].should_receive(:invoke).with(user1.id).exactly(1).times
    #Rake::Task['deliver:user'].should_receive(:invoke).with(user2.id).exactly(1).times
    Deliver.should_receive(:deliver).with(user1.id).exactly(1).times
    Deliver.should_receive(:deliver).with(user2.id).exactly(1).times

    subject.invoke
  end
end

describe "deliver:user" do
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return nil
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "call the proper function" do
    puts 'DEBUG:' + Rails.env.to_s
    user = FactoryGirl.create(:user)
    Deliver.stub(:deliver).and_return nil
    Deliver.should_receive(:deliver).with(user.id)

    subject.invoke user.id
  end
end

describe "deliver:update" do
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return nil
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "deliver recommended images to an user" do
    puts 'DEBUG:' + Rails.env.to_s
    user = FactoryGirl.create(:user_with_delivered_images, images_count: 5)
    Deliver.stub(:update).and_return nil
    Deliver.should_receive(:update)

    subject.invoke
  end
end
