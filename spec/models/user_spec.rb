require 'spec_helper'

describe User do
  let(:auth_twitter) { OmniAuth::AuthHash.new({
    provider: 'twitter',
    uid: '12345678',
    info: { nickname: 'ispick_twitter1'},     # Same name as the record produced from the users factory
    credentials: OmniAuth::AuthHash.new({})
  })}
  let(:auth_facebook) { OmniAuth::AuthHash.new({
    provider: 'facebook',
    uid: '12345678',
    #extra: { raw_info: { name:'John' }},
    info: { email:'test@example.com', last_name: 'Smith', first_name: 'John' },
    credentials: OmniAuth::AuthHash.new({})
  })}

  describe "association dependency" do
    it "destroys tags_users when destroyed" do
      user = FactoryGirl.create(:user_with_tags)
      user.destroy
      expect(TagsUser.count).to eq(0)
      # 5 tags followed by the user + 25 tags which are associated with images
      expect(Tag.count).to eq(30)
    end
  end


  describe "get_images method" do
    it "returns proper relation object" do
      user = FactoryGirl.create(:user_with_tag_images_file, images_count: 1)
      images = user.get_images
      expect(images.count).to eq(1)
    end
  end

  describe "get_images_all method" do
    it "returns proper relation object" do
      user = FactoryGirl.create(:user_with_tag_images_file, images_count: 1)
      images = user.get_images_all
      expect(images.count).to eq(1)
    end
  end

  describe "get_board method" do
    it "return the valid ImageBoard record" do
      user = FactoryGirl.create(:user)
      board_id = user.image_boards.first.id
      expect(user.get_board.class).to eq(ImageBoard)
      expect(user.get_board(board_id).class).to eq(ImageBoard)
    end
  end

  describe "create_defaul method" do
    it "returns a certain path" do
      user = User.new(email: 'test@example.com', password: '12345678', name: 'test')
      user.create_default
      expect(user.image_boards.count).to eq(1)
    end
  end


  # ===============================
  #  Authorization related methods
  # ===============================
  describe "from_omniauth method" do
    it "returns user if persisted" do
      user = FactoryGirl.create(:twitter_user)
      auth_user = User.from_omniauth(auth_twitter, nil)
      expect(User.count).to eq 1
    end

    it "creates a user if not persisted" do
      User.delete_all
      user = User.from_omniauth(auth_twitter, nil)
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
