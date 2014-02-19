require 'spec_helper'

describe "target_images/show" do
  before(:each) do
    @target_image = assign(:target_image, stub_model(TargetImage,
      :title => "Title"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
  end
end
