class WelcomeController < ApplicationController
  def index
    #@images = Image.search_images('pixiv').page(params[:page]).per(10)
    @images = Image.get_popular_recent_images(500).page(params[:page]).per(10)
    @images = Image.get_recent_images(500).page(params[:page]).per(10) if @images.empty?
    @first = true
    @first = false if params[:page] and params[:page].to_i > 1
    @disable_fotter = true
  end

  def signup
    #@images = Image.search_images('aqua eyes').page(params[:page]).per(10)
    @images = Image.get_popular_recent_images(500).page(params[:page]).per(10)
    @images = Image.search_images('pixiv').page(params[:page]).per(10) if @images.empty?
    @images = Image.get_recent_images(500).page(params[:page]).per(10) if @images.empty?
    @first = true
    @first = false if params[:page] and params[:page].to_i > 1
    @disable_fotter = true
  end
end
