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

  describe "find_for_facebook_oauth method" do
    it "should return user if persisted" do
      FactoryGirl.create(:facebook_user)
      user = User.find_for_twitter_oauth(auth_facebook, nil)
      expect(User.count).to eq 1
    end

    it "should create an user if not persisted" do
      User.delete_all
      user = User.find_for_facebook_oauth(auth_facebook, nil)
      expect(User.count).to eq 1
    end
  end

  describe "find_for_twitter_oauth method" do
    it "should return user if persisted" do
      FactoryGirl.create(:twitter_user)
      user = User.find_for_twitter_oauth(auth_twitter, nil)
      expect(User.count).to eq 1
    end

    it "should create an user if not persisted" do
      user = User.find_for_twitter_oauth(auth_twitter, nil)
      expect(User.count).to eq 1
    end
  end

  describe "create_unique_string method" do
    it "should return random string" do
      expect(User.create_unique_string).to be_a(String)
    end
  end

  describe "create_unique_email method" do
    it "should include valid string" do
      expect(User.create_unique_email).to be_a(String)
      expect(User.create_unique_email).to match('@example.com')
    end
  end
end
