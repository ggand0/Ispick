class WelcomeController < ApplicationController
  def index
    @images = Image.search_images('pixiv').page(params[:page]).per(25)
    @images = Image.get_recent_images(500).page(params[:page]).per(25) if @images.nil?
    @first = true
    @first = false if params[:page] and params[:page].to_i > 1
  end

  def signup
    @images = Image.search_images('aqua eyes').page(params[:page]).per(25)
    @images = Image.search_images('pixiv').page(params[:page]).per(25) if @images.nil?
    @images = Image.get_recent_images(500).page(params[:page]).per(25) if @images.nil?
    @first = true
    @first = false if params[:page] and params[:page].to_i > 1
  end
end
