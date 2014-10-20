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

  describe "search_images method" do
    it "returns a valid image relation" do
      FactoryGirl.create(:tag_with_images, images_count: 5)
      images = Image.search_images('鹿目まどか1')
      expect(images.count).to eq(5)
    end
  end

  describe "filter_by_date method" do
    it "returns proper relation object" do
      user = FactoryGirl.create(:user_with_tag_images, images_count: 1)
      images = user.tags.first.images
      date_string = 'Mon Sep 01 2014 00:00:00 GMT 0900 (JST)'
      date = DateTime.parse(date_string).to_date

      expect(Image.filter_by_date(images, date).count).
        to eq(0)
    end
  end

  describe "filter_by_illust method" do
    it "returns proper relation object" do
      user = FactoryGirl.create(:user_with_tag_images, images_count: 1)
      images = user.get_images

      # The above code creates user.images with an illust and a photo,
      # So it should be 1
      expect(Image.filter_by_illust(images, 'photo').count).to eq(0)
    end
  end

  describe "sort_images method" do
    it "returns proper relation object" do
      user = FactoryGirl.create(:user_with_tag_dif_image)
      images = user.get_images
      first = images[0]
      second = images[1]

      result = Image.sort_images(images, 1)
      expect(result[1]).to eq(second)
      expect(result[0]).to eq(first)
    end
  end

  describe "sort_by_quality method" do
    it "returns proper relation object" do

    end
  end

end
