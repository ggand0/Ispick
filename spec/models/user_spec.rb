require 'spec_helper'

describe User do
  let(:auth_twitter) { OmniAuth::AuthHash.new({
    provider: 'twitter',
    uid: '12345678',
    info: { nickname: 'John'}
  })}
  let(:auth_facebook) { OmniAuth::AuthHash.new({
    provider: 'facebook',
    uid: '12345678',
    extra: { raw_info: {name:'John'}},
    info: {email:'test@example.com'}
  })}


  # TODO: include a delivered_image from twitter
  describe "get_images" do
    it "returns proper relation object" do
      #user = FactoryGirl.create(:user_with_images)
      user = FactoryGirl.create(:user_with_target_word_image)
      images = user.get_images
      expect(images.count).to eq(1)
    end
  end

  # TODO: include a delivered_image from twitter
  describe "get_images_all" do
    it "returns proper relation object" do
      #user = FactoryGirl.create(:user_with_images)
      user = FactoryGirl.create(:user_with_target_word_image)
      images = user.get_images
      expect(images.count).to eq(1)
    end
  end

  describe "filter_by_date" do
    it "returns proper relation object" do
      user = FactoryGirl.create(:user_with_target_word_image)
      images = user.target_words.first.images

      expect(User.filter_by_date(images, DateTime.now.utc.to_date).count).
        to eq(0)
    end
  end

  describe "filter_by_illust" do
    it "returns proper relation object" do
      #user = FactoryGirl.create(:user_with_images)
      user = FactoryGirl.create(:user_with_target_word_image)
      images = user.get_images

      # Since user.images contain an illust image and a photo image,
      # it should be 1
      expect(User.filter_by_illust(images, 'photo').count).to eq(0)
    end
  end

  describe "sort_images" do
    it "returns proper relation object" do
      user = FactoryGirl.create(:user_with_target_word_dif_image)
      images = user.get_images
      first = images[0]
      second = images[1]

      result = User.sort_images(images, 1)
      expect(result[1]).to eq(second)
      expect(result[0]).to eq(first)
    end
  end

  describe "sort_by_quality" do
    it "returns proper relation object" do

    end
  end

  describe "create_default" do
    it "returns a certain path" do
      user = User.new(email: 'test@example.com', password: '12345678', name: 'test')
      user.create_default
      expect(user.image_boards.count).to eq(1)
    end
  end

  describe "get_board" do
    it "return the valid ImageBoard record" do
      user = FactoryGirl.create(:user)
      board_id = user.image_boards.first.id
      expect(user.get_board.class).to eq(ImageBoard)
      expect(user.get_board(board_id).class).to eq(ImageBoard)
    end
  end


  # ===============================
  #  Authorization related methods
  # ===============================
  describe "find_for_facebook_oauth method" do
    it "returns user if persisted" do
      FactoryGirl.create(:facebook_user)
      user = User.find_for_twitter_oauth(auth_facebook, nil)
      expect(User.count).to eq 1
    end

    it "creates a user if not persisted" do
      User.delete_all
      user = User.find_for_facebook_oauth(auth_facebook, nil)
      expect(User.count).to eq 1
    end
  end

  describe "find_for_twitter_oauth method" do
    it "returns user if persisted" do
      FactoryGirl.create(:twitter_user)
      user = User.find_for_twitter_oauth(auth_twitter, nil)
      expect(User.count).to eq 1
    end

    it "creates a user if not persisted" do
      user = User.find_for_twitter_oauth(auth_twitter, nil)
      expect(User.count).to eq 1
    end
  end

  describe "create_unique_string method" do
    it "returns random string" do
      expect(User.create_unique_string).to be_a(String)
    end
  end

  describe "create_unique_email method" do
    it "includes valid string" do
      expect(User.create_unique_email).to be_a(String)
      expect(User.create_unique_email).to match('@example.com')
    end
  end
end
