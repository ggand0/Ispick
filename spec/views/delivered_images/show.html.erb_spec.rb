require 'spec_helper'

describe "delivered_images/show" do
  before(:each) do
    @delivered_image = FactoryGirl.create(:delivered_image)
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
  end
end
