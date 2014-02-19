require 'spec_helper'

describe "target_images/edit" do
  before(:each) do
    @target_image = assign(:target_image, stub_model(TargetImage,
      :title => "MyString"
    ))
  end

  it "renders the edit target_image form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", target_image_path(@target_image), "post" do
      assert_select "input#target_image_title[name=?]", "target_image[title]"
    end
  end
end
