class WelcomeController < ApplicationController
  def index
    #@images = Image.search_images('pixiv').page(params[:page]).per(10)
    @images = Image.get_popular_recent_images(500).page(params[:page]).per(10)
    @images = Image.get_recent_images(500).page(params[:page]).per(10) if @images.empty?
    @first = true
    @first = false if params[:page] and params[:page].to_i > 1
    @disable_fotter = true
    @pagination = false
  end

  def signup
    #@images = Image.search_images('aqua eyes').page(params[:page]).per(10)
    @images = Image.get_popular_recent_images(500).page(params[:page]).per(10)
    @images = Image.search_images('pixiv').page(params[:page]).per(10) if @images.empty?
    @images = Image.get_recent_images(500).page(params[:page]).per(10) if @images.empty?
    @first = true
    @first = false if params[:page] and params[:page].to_i > 1
    @disable_fotter = true
    @pagination = false
  end

  def tags
    @tags = Tag.get_tags_with_images(1000)
    @search_tags = Tag.search(params[:q])
    if params[:q]
      @tags_result = @search_tags.result(distinct: true).page(params[:page]).per(1000)
    end
  end

  def ranking
    @images = RankingImage.get_images.page(params[:page]).per(10)
    @count = @images.count
    @disable_fotter = true
    @pagination = false
  end

  def ranking_realtime
    @images = Image.get_ranking_images(100).page(params[:page]).per(10)
    @count = @images.count
    @disable_fotter = true
    @pagination = false
  end
end
