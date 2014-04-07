require 'spec_helper'

describe "target_words/show" do
  before(:each) do
    @target_word = FactoryGirl.create(:word_with_delivered_images, images_count: 5)
    @target_word.person = FactoryGirl.create(:person_madoka)
    @delivered_images = @target_word.delivered_images.page(params[:page]).per(25)
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Word/)
  end
end
