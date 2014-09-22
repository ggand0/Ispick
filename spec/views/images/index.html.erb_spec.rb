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
    assert_select "img", count: 2
  end
end
