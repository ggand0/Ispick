require 'spec_helper'

describe DebugController do

  describe "GET 'index'" do
    it "renders 'signin_with_password' template when the user is NOT logged in" do
      get :index
      expect(response).to redirect_to('/signin_with_password')
    end

    it "renders 'home' template when the user is logged in" do
      login_user
      get :index
      expect(response).to render_template('debug/index')
    end
  end

  describe "GET download_recent_images" do
    it "downloads recent images" do
      login_user
      allow(controller).to receive(:render).and_return nil
      expect(controller).to receive(:send_file)
      get :download_images_n, {}
    end

    it "downloads recent images that have proper filenames" do
      login_user
      get :download_images_n, {}
    end
  end

  describe "GET download_tag" do
    it "downloads recent images" do
      login_user
      allow(controller).to receive(:render).and_return nil
      expect(controller).to receive(:send_file)
      get :download_images_tag, {}
    end
  end

  describe "GET debug_illust_detection" do
    it "renders valid template" do
      login_user
      get :debug_illust_detection, {}
      expect(response).to render_template('debug_illust_detection')
    end
  end

end
