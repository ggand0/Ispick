require 'spec_helper'

describe UsersController do
  let(:valid_session) { {} }
  after do
    sign_out :user
  end

  describe "GET home" do
    it "renders 'signin_with_password' template when the user is NOT logged in" do
      get :home, {}, valid_session
      expect(response).to redirect_to('/signin_with_password')
    end

    it "renders 'home' template when the user is logged in" do
      login_user
      get :home, {}, valid_session
      expect(response).to render_template('home')
    end

    it "does something" do
      login_user
      get :home, { date: 'Mon Sep 01 2014 00:00:00 GMT 0900 (JST)' }, valid_session
    end
  end

  describe "GET new_avatar" do
    it "renders proper partial" do
      login_user
      get :new_avatar, :format => 'js'

      expect(response).to render_template('users/_new_avatar')
    end
  end

  describe "POST create_avatar" do
    it "updates avatar image" do
      login_user
      request.env['HTTP_REFERER'] = '/'

      post :create_avatar, { id: User.first.id, avatar: fixture_file_upload("files/madoka0.jpg") }
      expect(User.first.avatar).not_to eq(nil)
    end
  end

  describe "PUT update" do
    it "updates a user correctly" do
      login_user
      put :update, { id: User.first.id, user: { name: 'madoka'}}
      expect(User.first.name).to eq('madoka')
    end
  end

  describe "GET search" do
    it "Search and render the right images" do
      login_user
      image1 = FactoryGirl.create(:image_with_tags)

      get :search, { query: '鹿目まどか6', page: 1 }

      response.should render_template('home')
      expect(assigns(:images).count).to eq(1)
      expect(assigns(:images).first).to eq(image1)
    end
  end


  describe "GET show_target_images" do
    it "renders show_target_images template when logged in" do
      login_user
      get :show_target_images, {}, valid_session
      response.should render_template('debug/_show_target_images')
    end

    it "renders not_signed_in template when NOT logged in" do
      get :show_target_images, {}, valid_session
      expect(response).to redirect_to('/signin_with_password')
    end
  end

  describe "GET show_target_words" do
    it "renders 'preferences' template when logged in" do
      login_user
      get :preferences, {}, valid_session
      response.should render_template('preferences')
    end

    it "renders 'not_signed_in' template when NOT logged in" do
      get :preferences, {}, valid_session
      expect(response).to redirect_to('/signin_with_password')
    end
  end

  describe "GET boards" do
    it "renders show_target_images template when logged in" do
      login_user
      get :boards, {}, valid_session
      response.should render_template('boards')
    end

    it "renders not_signed_in template when NOT logged in" do
      get :boards, {}, valid_session
      expect(response).to redirect_to('/signin_with_password')
    end
  end


  describe "DELETE delete_target_word" do
    it "deletes a target_word only from the User.target_words relation" do
      login_user
      user = User.first
      word_count = TargetWord.count
      user_count = user.target_words.count
      target_word = user.target_words.first

      delete :delete_target_word, { id: target_word.id }

      expect(response).to render_template('preferences')
      expect(TargetWord.count).to eq(word_count)
      expect(user.target_words.count).to eq(user_count-1  )
    end
  end

  # ==========================
  #  specs of private methods
  # ==========================
=begin
  describe "update_session" do
    controller = UsersController.new
    puts "#{User.count} #{DeliveredImage.count}"
    puts controller.session
    params = { all: true, sort: true }

    result = controller.send(:update_session, params)
    puts result.count
  end
=end

end
