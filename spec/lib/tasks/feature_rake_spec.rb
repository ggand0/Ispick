require 'spec_helper'
require 'rake'

describe "feature:reset_convnet" do
  before do
    #IO.any_instance.stub(:puts)
    Ispick::Application.load_tasks
  end

  it "calls valid methods" do
    FactoryGirl.create(:image)

    puts Image.count
    expect(Resque).to receive(:enqueue).at_least(:once)
    Rake::Task['feature:reset_convnet'].invoke
    #expect(Image.first.feature).not_to eq(nil)
  end
end

=begin
describe "feature:face_targets" do
  # 諸々の初期化。gemの仕様的にこれ以上DRYにできない
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return nil # resqueにenqueueしないように
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "should call valid a methods" do
    FactoryGirl.create(:target_image)
    TargetImagesService.any_instance.stub(:prefer).and_return({result: '[]'})
    TargetImagesService.any_instance.should_receive(:prefer)

    subject.invoke
    TargetImage.first.feature.face.should eq ('[]'.to_json)
  end
end

describe "feature:face_images" do
  before do
    IO.any_instance.stub(:puts)
    Resque.stub(:enqueue).and_return nil
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "should call valid a methods" do
    Image.delete_all
    FactoryGirl.create(:image)

    TargetImagesService.any_instance.stub(:prefer).and_return({ result: '[]' })
    TargetImagesService.any_instance.should_receive(:prefer)

    subject.invoke
    Image.first.feature.face.should eq ('[]'.to_json)
  end
end
=end