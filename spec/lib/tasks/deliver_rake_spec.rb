require 'spec_helper'

describe "deliver:all" do
  # 諸々の初期化。gemの仕様的にこれ以上DRYにできない
  before do
    IO.any_instance.stub(:puts)
    # resqueにenqueueしないように
    Resque.stub(:enqueue).and_return
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "deliver images to all users" do
    user = FactoryGirl.create(:user)
    Rake::Task['deliver:user'].stub(:invoke).and_return
    Rake::Task['deliver:user'].should_receive(:invoke).exactly(1).times
    subject.invoke
  end
end

describe "deliver:user" do
  # 諸々の初期化。gemの仕様的にこれ以上DRYにできない
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "call the proper function" do
    puts 'DEBUG:' + Rails.env.to_s
    user = FactoryGirl.create(:user)
    Deliver.should_receive(:deliver).with(user.id)

    subject.invoke user.id
  end
end

describe "deliver:update" do
  # 諸々の初期化。gemの仕様的にこれ以上DRYにできない
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "deliver recommended images to an user" do
    puts 'DEBUG:' + Rails.env.to_s
    user = FactoryGirl.create(:user_with_delivered_images, images_count: 5)
    Deliver.should_receive(:update)
    Deliver.update()
  end
end
