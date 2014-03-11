require 'spec_helper'

describe "delivered_images/index" do
  before(:each) do
    assign(:delivered_images, [
      stub_model(DeliveredImage,
        :title => "MyText",
        :caption => "MyText",
        :src_url => "MyText"
      ),
      stub_model(DeliveredImage,
        :title => "MyText",
        :caption => "MyText",
        :src_url => "MyText"
      )
    ])
  end

  it "renders a list of delivered_images" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
