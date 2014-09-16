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

    it "save an image with extension" do
      image = Image.new valid_attributes
      url = 'http://www.madoka-magica.com/tv/character/img/chara1_img.png'
      image.image_from_url(url)
      expect(image.data.url).to match('png')
    end
  end

  describe "get_recent_images" do
    it "returns a relation object that has same length as the limit arg" do
      FactoryGirl.create_list(:image_file, 6)
      result = Image.get_recent_images(5)
      expect(result.count).to eq(5)
    end
  end

end
