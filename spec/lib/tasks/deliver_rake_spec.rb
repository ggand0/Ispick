require 'spec_helper'

describe "deliver:all" do
  # 諸々の初期化。gemの仕様的にこれ以上DRYにできない
  before do
    IO.any_instance.stub(:puts)
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
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "deliver recommended images to an user" do
    puts 'DEBUG:' + Rails.env.to_s
    user = FactoryGirl.create(:user)
    #user = User.create(email: 'test@example.com', password: '12345678')

    face_feature = FactoryGirl.create(:feature_madoka)          # target_image
    target_image = TargetImage.find(face_feature.featurable_id)
    FactoryGirl.create(:feature_madoka1)                        # 似てるimage
    FactoryGirl.create(:feature_madoka2)                        # 似てないimage
    user.target_images << TargetImage.first
    puts 'USER:' + user.id.to_s + ' / ' + User.count.to_s
    puts 'IMAGE:' + Image.first.id.to_s + ' / ' + Image.count.to_s

    subject.invoke user.id
    expect(user.delivered_images.count).to eq(1)
  end
end
