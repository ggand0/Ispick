require 'spec_helper'

describe Image do
  let(:valid_attributes) { { "title" => "MyString" } }

  describe "image_from_url" do

  	it "assigns argument as data" do
      image = Image.new valid_attributes
      image.image_from_url("http://dic.nicovideo.jp/oekaki/344522.png")
      #image.data.url.should eq("http://dic.nicovideo.jp/oekaki/344522.png")
      image.data.should_not be_nil
    end
  end

end
