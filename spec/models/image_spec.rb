require 'spec_helper'

describe Image do
  let(:valid_attributes) { { "title" => "MyString" } }

  before do
    allow_any_instance_of(IO).to receive(:puts)             # Suppress console outputs
  end


  describe "destroys image file and paperclip attachment before being destroyed" do
    it "destroying" do
      image = FactoryGirl.create(:image_file)
    end
  end

  describe "image_from_url" do
  	it "assigns argument as data" do
      image = Image.new valid_attributes
      url = 'http://goo.gl/4b7UUc'
      image.image_from_url(url)
      expect(image.data).not_to be_nil
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

  describe "get_recent_images_relation" do
    it "returns a valid relation" do
      FactoryGirl.create_list(:image, 2)
      images = Image.all
      result = Image.get_recent_images_relation(images, 'nicoseiga')
      expect(result.count).to eq(1)
    end
  end

  describe "get_title" do
    it "returns a valid string" do
      image = FactoryGirl.create(:image_file)
      result = image.get_title

      expect(result).to be_a(String)
      expect(result).to eq('madoka.jpg')
    end
  end

  describe "create_list_file" do
    it "writes image names to a file" do
      images = FactoryGirl.create_list(:image_file, 2)
      result = Image.create_list_file(images)
      expect(result).to be_a(Tempfile)
    end
  end

  describe "create_list_file_train_val method" do
    it "writes image names to 'train' and 'val' file" do
      images = FactoryGirl.create_list(:image_file, 5)
      image_array = [
        { image: images[0], label: 0 },
        { image: images[1], label: 0 },
        { image: images[2], label: 1 },
        { image: images[3], label: 2 },
        { image: images[4], label: 2 },
      ]

      result = Image.create_list_file_train_val(image_array)
      expect(result[0]).to be_a(Tempfile)
      expect(result[1]).to be_a(Tempfile)

      # Check file content
      puts File.read(result[0]).inspect
      puts "\n"
      puts File.read(result[1]).inspect

      expect(File.read(result[0])).to eq("madoka.jpg 0\nmadoka.jpg 1\nmadoka.jpg 2\n")
      expect(File.read(result[1])).to eq("madoka.jpg 0\nmadoka.jpg 2\n")
    end
  end

  describe "search_images method" do
    it "returns a valid image relation" do
      # Note that search_images exclude image records without actual file
      FactoryGirl.create(:tag_with_image_file, images_count: 5)
      #puts Image.first.tags.first.name
      images = Image.search_images('鹿目まどか1')
      expect(images.count).to eq(5)
    end
  end

  describe "search_images_tags method" do
    it "returns a valid relation with OR condition" do
      FactoryGirl.create(:image_madoka)
      FactoryGirl.create(:image_sayaka)
    end
    it "returns a valid relation with AND condition" do
      FactoryGirl.create(:image_madoka)
      FactoryGirl.create(:image_madoka_single)

      images = Image.search_images_tags(['Madoka Kaname', 'single'], 'and')
      expect(images.count).to eq(1)
    end
  end

  describe "search_images_custom method" do
    it "returns a valid relation" do
      # Gather all single character images
      FactoryGirl.create(:person_madoka)
      FactoryGirl.create(:person_sayaka)
      FactoryGirl.create(:image_madoka)
      FactoryGirl.create(:image_sayaka)
      i1 = FactoryGirl.create(:image_madoka_single)
      i2 = FactoryGirl.create(:image_sayaka_single)

      result = Image.search_images_custom
      expect(result.count).to eq(2)
    end

    it "returns a valid relation" do
      # Gather all single character images
      FactoryGirl.create(:person_madoka)
      FactoryGirl.create(:person_sayaka)
      FactoryGirl.create(:image_madoka)
      FactoryGirl.create(:image_sayaka)
      i1 = FactoryGirl.create(:image_madoka_single)
      i2 = FactoryGirl.create(:image_sayaka_single)

      result = Image.search_images_custom(1)
      expect(result.count).to eq(1)
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
