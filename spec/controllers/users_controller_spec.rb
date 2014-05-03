require 'spec_helper'

describe UsersController do
  let(:valid_session) { {} }

  describe "GET home" do
    it "should render signed_in template when logged in" do
      login_user
      get :home, {}, valid_session
      response.should render_template('signed_in')
      sign_out :user
    end

    it "should render not_signed_in template when NOT logged in" do
      get :home, {}, valid_session
      response.should render_template('not_signed_in')
    end
  end

  describe "GET show_illusts" do
    it "should render signed_in template when logged in" do
      login_user
      get :show_illusts, {}, valid_session
      response.should render_template('signed_in')
      sign_out :user
    end

    it "assigns delivered_images with records that have true value in its 'is_illust' column" do
      login_user
      user = User.first
      user.delivered_images << FactoryGirl.create(:delivered_image_photo)
      user.delivered_images << FactoryGirl.create(:delivered_image)
      #user = FactoryGirl.create(:user_with_delivered_images)

=begin
      user.delivered_images.each { |n| puts n.image.is_illust }
      puts Image.count
      puts DeliveredImage.count
      puts Image.where(is_illust: true).count
      puts user.delivered_images.joins(:image).where(images: { is_illust: true }).count
      #puts controller.current_user.delivered_images.scope().includes(:image).where('images.is_illust=?', true).references(:images).count
=end

      get :show_illusts, {}, valid_session
      expect(assigns(:delivered_images).count).to eq(1)

      sign_out :user
    end

    it "should render not_signed_in template when NOT logged in" do
      get :show_illusts, {}, valid_session
      response.should render_template('not_signed_in')
    end
  end

  describe "GET show_target_images" do
    it "should render show_target_images template when logged in" do
      login_user
      get :show_target_images, {}, valid_session
      response.should render_template('show_target_images')
      sign_out :user
    end
    it "should render not_signed_in template when NOT logged in" do
      get :show_target_images, {}, valid_session
      response.should render_template('not_signed_in')
    end
  end

  describe "GET show_target_words" do
    it "render show_target_words template when logged in" do
      login_user
      get :show_target_words, {}, valid_session
      response.should render_template('show_target_words')
      sign_out :user
    end
    it "render not_signed_in template when NOT logged in" do
      get :show_target_words, {}, valid_session
      response.should render_template('not_signed_in')
    end
  end

  describe "GET show_favored_images" do
    it "should render show_target_images template when logged in" do
      login_user
      get :show_favored_images, {}, valid_session
      response.should render_template('show_favored_images')
      sign_out :user
    end
    it "should render not_signed_in template when NOT logged in" do
      get :show_favored_images, {}, valid_session
      response.should render_template('not_signed_in')
    end
  end

  describe "GET download_favored_images" do
    # http://stackoverflow.com/questions/4701108/rspec-send-file-testing
    it "downloads favored delivered_images" do
      FactoryGirl.create(:delivered_image_favored)
      sign_in User.first
      controller.should_receive(:send_file).and_return{controller.render nothing: true}
      get :download_favored_images, {}, valid_session
    end

    it "should render not_signed_in template when NOT logged in" do
      # rootにいたと仮定
      request.env['HTTP_REFERER'] = '/'
      get :download_favored_images, {}, valid_session
      # redirect_to :backされるはず
      expect(response).to redirect_to '/'
    end
  end
end
