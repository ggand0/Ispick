require 'spec_helper'

describe "delivered_images/show" do
  before(:each) do
    @delivered_image = assign(:delivered_image, stub_model(DeliveredImage,
      :title => "MyText",
      :caption => "MyText",
      :src_url => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
  end
end
