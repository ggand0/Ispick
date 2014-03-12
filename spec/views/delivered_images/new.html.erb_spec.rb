require 'spec_helper'

describe "delivered_images/new" do
  before(:each) do
    assign(:delivered_image, stub_model(DeliveredImage,
      :title => "MyText",
      :caption => "MyText",
      :src_url => "MyText"
    ).as_new_record)
  end

  it "renders new delivered_image form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", delivered_images_path, "post" do
      assert_select "textarea#delivered_image_title[name=?]", "delivered_image[title]"
      assert_select "textarea#delivered_image_caption[name=?]", "delivered_image[caption]"
      assert_select "textarea#delivered_image_src_url[name=?]", "delivered_image[src_url]"
    end
  end
end
