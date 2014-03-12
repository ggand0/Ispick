require 'spec_helper'

describe Image do
  let(:valid_attributes) { { "title" => "MyString" } }

  describe "image_from_url" do
  	it "assigns argument as data" do
      image = Image.new valid_attributes
      url = 'http://goo.gl/4b7UUc'
      image.image_from_url(url)
      image.data.should_not be_nil
    end
  end

end
