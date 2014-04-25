require 'spec_helper'

describe "images/show" do
  before(:each) do
    @image = assign(:image, stub_model(Image,
      title: 'Title',
      caption: 'Caption',
      src_url: 'http://goo.gl/4b7UUc',
      page_url: 'http://goo.gl/8icNI9'
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Caption/)
  end
end
