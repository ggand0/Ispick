require 'spec_helper'

describe Image do
  let(:valid_attributes) { { "title" => "MyString" } }

  describe "image_from_url" do
  	it "assigns argument as data" do
      image = Image.new valid_attributes
      #url = 'http://upload.wikimedia.org/wikipedia/commons/8/80/Wikipedia-logo-v2.svg'
      url = 'http://upload.wikimedia.org/wikipedia/commons/e/ea/Henry_V_of_England_-_Illustration_from_Cassell%27s_History_of_England_-_Century_Edition_-_published_circa_1902.jpg'
      image.image_from_url(url)
      image.data.should_not be_nil
    end
  end

end
