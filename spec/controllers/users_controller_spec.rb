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
