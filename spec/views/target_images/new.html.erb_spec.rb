require 'spec_helper'

describe "target_images/new" do
  before(:each) do
    assign(:target_image, stub_model(TargetImage,
    ).as_new_record)
  end

  it "renders new target_image form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    #assert_select "form[action=?][method=?]", target_images_path, "post" do
    #  assert_select "input#target_image_title[name=?]", "target_image[title]"
    #end
  end
end
