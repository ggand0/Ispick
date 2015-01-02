class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit, :update, :destroy, :favor, :hide]

  # GET /images
  # GET /images.json
  def index
    @images = Image.all.page(params[:page])
  end

  # GET /images/1
  # GET /images/1.json
  def show
    respond_to do |format|
      format.html {}
      format.js { render partial: 'show' }
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.destroy
    respond_to do |format|
      format.html { redirect_to images_url }
      format.json { head :no_content }
    end
  end


  # PUT favor
  # Add image to board as a favored_image.
  # TODO: Refactor!
  def favor
    board_name = params[:board]

    # Create a FavoredImage object
    # If src_url was duplicate, it returns false due to the validation
    # This code assumes that parameters contain a board name
    board = current_user.image_boards.where(name: board_name).first
    favored_image = board.favored_images.build(
      artist: @image.artist,
      poster: @image.poster,
      title: @image.title,
      caption: @image.caption,
      data: @image.data,
      src_url: @image.src_url,
      original_url: @image.original_url,
      page_url: @image.page_url,
      site_name: @image.site_name,
      original_view_count: @image.original_view_count,
      original_favorite_count: @image.original_favorite_count,
      width: @image.width,
      height: @image.height,
      posted_at: @image.posted_at,
    )
    @image.tags.each do |tag|
      favored_image.tags << tag
    end

    # Once it saves favored_image, add association to image
    if favored_image.save
      @image.favored_images << favored_image
    end

    # If request type is JS, call 'boards' template to reload the popover
    @clipped_board = board_name
    @board = ImageBoard.new
    @id = params[:html_id]
    respond_to do |format|
      format.html { redirect_to boards_users_path }
      format.js { render partial: 'image_boards/after_clipped' }
    end
  end

  # PUT hide
  # TODO: Need refactoring
  def hide
    if not @image.avoided
      @image.update_attributes!(avoided: true)
    else
      @image.update_attributes!(avoided: false)
    end
    redirect_to :back
  end


  # =============
  #  RSS actions
  # =============
  def rss_aqua
    @images = Image.search_images('aqua eyes')

    respond_to do |format|
      format.rss { render :layout => false }
    end
  end

  # GET search
  def search
    # Ransack search
    if params[:q] and params[:q]['tags_name_cont']
      queries = params[:q]['tags_name_cont'].split(',')
      images = Image.joins(:tags).
        where('tags.name' => queries).
        group("images.id").having("count(*)= #{queries.count}")
      images = images.where.not(data_updated_at: nil)
      images = filter_sort(images)

      @count = images.select('images.id').count.keys.count
      @query = { q: { "tags_name_cont" => params[:q]['tags_name_cont'] }}

    # Single search
    else
      images = Image.search_images(params[:query])
      images = filter_sort(images)
      @count = images.select('images.id').count
      @query = { query: params[:query] }
    end

    @disable_fotter = true
    @images = images.page(params[:page]).per(10)
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    end

    def filter_sort(images)
      images.reorder!('posted_at DESC') if params[:sort]
      if params[:date]
        date = DateTime.parse(params[:date]).to_date
        images = Image.filter_by_date(images, date)
      end
      if params[:site]
        images = Image.filter_by_date(images, params[:site])
      end
      images
    end
end
