require 'spec_helper'

describe "images/index" do
  before(:each) do
    assign(:images, Kaminari.paginate_array([
      stub_model(Image,
        :title => "Title",
        :caption => "Caption"
      ),
      stub_model(Image,
        :title => "Title",
        :caption => "Caption"
      )
    ]).page(1))
  end

  it "renders a list of images" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    #assert_select "tr>td", :text => "Title".to_s, :count => 2
    #assert_select "tr>td", :text => "Caption".to_s, :count => 2
    assert_select "img", count: 2
  end
end
