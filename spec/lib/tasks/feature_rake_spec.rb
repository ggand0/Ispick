require 'spec_helper'
require 'rake'

describe "feature rake tasks" do
  before do
    allow_any_instance_of(IO).to receive(:puts)
    Ispick::Application.load_tasks
  end

  describe "feature:reset_convnet" do
    it "calls valid methods" do
      FactoryGirl.create(:image)

      puts Image.count
      expect(Resque).to receive(:enqueue).at_least(:once)
      Rake::Task['feature:reset_convnet'].invoke
      #expect(Image.first.feature).not_to eq(nil)
    end
  end

  describe "feature:face_targets" do
    it "should call valid a methods" do
      FactoryGirl.create(:target_image)
      allow_any_instance_of(TargetImagesService).to receive(:prefer).and_return({result: '[]'})
      expect_any_instance_of(TargetImagesService).to receive(:prefer)

      Rake::Task['feature:face_targets'].invoke
      expect(TargetImage.first.feature.face).to eq ('[]'.to_json)
    end
  end

  describe "feature:face_images" do
    it "should call valid a methods" do
      Image.delete_all
      FactoryGirl.create(:image)

      allow_any_instance_of(TargetImagesService).to receive(:prefer).and_return({ result: '[]' })
      expect_any_instance_of(TargetImagesService).to receive(:prefer)

      Rake::Task['feature:face_images'].invoke
      expect(Image.first.feature.face).to eq ('[]'.to_json)
    end
  end
end