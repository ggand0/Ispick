class DebugController < ApplicationController
  before_action :render_sign_in_page
  before_filter :authenticate
  before_action :set_image, only: [:favor_another, :show_debug]
  #before_action :set_image_board, only: [:create_another]

  def index
  end

  # =======================
  #  Actions for debugging
  # =======================
  def home
    # Get images: For a new user, display the newer images
    if current_user.target_words.empty?
      images = Image.get_recent_images(500)

    # Otherwise, display images from user.target_words relation
    else
      images = current_user.get_images
      images.reorder!('posted_at DESC') if params[:sort]
    end

    # Filter images by date
    if params[:date]
      date = DateTime.parse(params[:date]).to_date
      images = Image.filter_by_date(images, date)
    end

    @images = images.page(params[:page]).per(25)
    @images_all = images
  end

  # [DEBUG]Download images of the default image_board.
  # This feature will be deleted in future.
  # 画像のダウンロード：releaseする時にこの機能は削除する。
  def download_favored_images
    @images = current_user.image_boards.first.favored_images
    file_name  = "user#{current_user.id}-#{DateTime.now}.zip"

    temp_file  = Tempfile.new("#{file_name}-#{current_user.id}")
    Zip::OutputStream.open(temp_file.path) do |zos|
      @images.each do |image|
        title = "#{image.title}#{File.extname(image.data.path)}"
        zos.put_next_entry(title)
        zos.print IO.read(image.data.path)
      end
    end
    send_file temp_file.path, type: 'application/zip',
      disposition: 'attachment', filename: file_name
    temp_file.close
  end

  # The page for debugging illust detection feature.
  # イラスト判定ツールのデバッグ用ページを表示する。
  def debug_illust_detection
    # Get images
    if session[:all]
      images = current_user.get_images_all
    else
      images = current_user.get_images
    end

    # Filter by is_an_illustration value
    @debug = get_session_data
    images = Image.filter_by_illust(images, session[:illust])

    # Sort images if any requests exist.
    images = Image.sort_images(images, params[:page]) if session[:sort] == 'favorites'
    images = Image.sort_by_quality(images, params[:page]) if session[:sort] == 'quality'
    @images = images.page(params[:page]).per(25)

    render action: 'debug_illust_detection'
  end

  # [DEBUG]Just an old version of 'preferences' template,
  # which contains the 'create a target_word' link.
  def debug_crawling
    @words = current_user.target_words
    render action: 'debug_crawling'
  end

  # [DEBUG]
  def toggle_miniprofiler
    Rack::MiniProfiler.config.auto_inject = Rack::MiniProfiler.config.auto_inject ? false : true
    redirect_to home_users_path
  end


  # ======================
  #  Clip buttons related
  # ======================
  # POST /image_boards
  def create_another
    @image_board = ImageBoard.new(image_board_params)
    @image_board.save!
    current_user.image_boards << @image_board
    @image = Image.find(params[:image])
    @board = ImageBoard.new
    @id = params[:html_id]
    respond_to do |format|
      format.html { render nothing: true }
      format.js { render partial: 'boards_another' }
    end
  end
  def boards_another
    @image = Image.find(params[:image])
    @board = ImageBoard.new
    @id = params[:id]
    respond_to do |format|
      format.html { render partial: 'shared/popover_board', locals: { image: @image, image_board: @board, html: @id } }
      format.js { render partial: 'boards_another' }
    end
  end

  # ===============
  #  DEBUG actions
  # ===============
  def favor_another
    board_name = params[:board]
    board = current_user.image_boards.where(name: board_name).first
    favored_image = board.favored_images.build(
      title: @image.title,
      caption: @image.caption,
      data: @image.data,
      src_url: @image.src_url,
      page_url: @image.page_url,
      site_name: @image.site_name,
      views: @image.views,
      favorites: @image.favorites,
      posted_at: @image.posted_at,
    )
    @image.tags.each do |tag|
      favored_image.tags << tag
    end

    if favored_image.save
      @image.favored_images << favored_image
    end
    @clipped_board = board_name
    @board = ImageBoard.new
    @id = params[:html_id]
    respond_to do |format|
      format.html { redirect_to boards_users_path }
      format.js { render partial: 'boards_another' }
    end
  end

  def show_debug
    respond_to do |format|
      format.js { render partial: 'show_image_debug' }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_image
    @image = Image.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def image_board_params
    params.require(:image_board).permit(:name)
  end

  # Render the 'sign in' template if the user is logged in.
  def render_sign_in_page
    redirect_to '/signin_with_password' unless signed_in?
  end

  # Update session values based on request parameters.
  def update_session
    session[:all] = (not session[:all]) if params[:toggle_site]
    session[:sort] = params[:sort] if params[:sort]
    session[:illust] ||= 'all'
    session[:illust] = params[:illust] if params[:illust]
  end

  # Returns the session data for debugging.
  # デバッグ用にsessionの情報を返す。
  # @return [Array] String array of session data
  def get_session_data
    [
      "filter_illust: #{session[:illust]}",
      "sort_type: #{session[:sort]}",
      "filter_site: #{session[:all]}",
    ]
  end
end
