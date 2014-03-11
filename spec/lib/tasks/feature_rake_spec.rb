describe "feature:face_targets" do
  # 諸々の初期化。gemの仕様的にこれ以上DRYにできない
  before do
    IO.any_instance.stub(:puts)
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
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "should call valid a methods" do
    Image.delete_all
    FactoryGirl.create(:image)

    TargetImagesService.any_instance.stub(:prefer).and_return({result: '[]'})
    TargetImagesService.any_instance.should_receive(:prefer)

    subject.invoke
    Image.first.feature.face.should eq ('[]'.to_json)
  end
end