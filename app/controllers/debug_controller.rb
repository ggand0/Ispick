class DebugController < ApplicationController
  before_filter :set_search
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


  # Download CSV file that enumerates all csv attributes
  def download_csv
    limit = params[:limit]
    all = params[:all]
    file_name  = "Ispick_csv_#{DateTime.now}.csv"
    temp_file  = Tempfile.new("#{file_name}")

    # This code is copied from OutputCSV module
    # TODO: Refactor this!
    CSV.open(temp_file.path, "wb") do |csv|
      row = ["image_id","page_url","original_width","original_height","artist","tags(separate by ';')"]
      csv << row

      images = Image.select('id, page_url, original_width, original_height, artist').all.limit(limit)
      images = Image.select('id, page_url, original_width, original_height, artist').all if all
      puts "==========================DEBUG: #{limit}"
      puts "==========================DEBUG: #{limit}"

      # Includes joining table
      images.includes(:tags).find_each do |image|
        row = []
        row.push(image.id)
        row.push(image.page_url)
        row.push(image.original_width)
        row.push(image.original_height)
        row.push(image.artist)

        tag_string = ""
        image.tags.each do |tag|
          tag_string += "#{tag.name};"
        end
        row.push(tag_string)

        csv << row
      end
    end

    send_file temp_file.path, type: 'application/csv',
      disposition: 'attachment', filename: file_name
    temp_file.close
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

  # [DEBUG] Download images that have a specific tag from an optional site.
  def download_images_tag
    limit = params[:limit]
    site = params[:site]
    tag = params[:tag]
    @images = Image.search_images(tag)
    @images = @images.where(site_name: site) if site
    @images = @images.limit(limit) if limit
    file_name = "#{site}_#{tag}#{DateTime.now}.zip"
    temp_file = Tempfile.new("#{file_name}-#{current_user.id}")

    Zip::OutputStream.open(temp_file.path) do |zos|
      zos.put_next_entry 'imagelist'
      zos.print IO.read(Image.create_list_file(@images))
      @images.each do |image|
        # To avoid creating nested directory, remove slashes
        # E.g. 'NARUTO/xxx_zerochan.jpg' will create 'NARUTO' dir above the file in the zip
        title = image.get_title
        zos.put_next_entry(title)
        zos.print IO.read(image.data.path)
      end
    end
    send_file temp_file.path, type: 'application/zip',
      disposition: 'attachment', filename: file_name
    temp_file.close
  end

  # [DEBUG] Download images that have a specific tag from an optional site.
  def download_images_tags
    limit = params[:limit]
    site = params[:site]
    tag = params[:tag]
    @image_array = []
    tags = tag.split(':')#

    tags.each do |tag|
      t = tag.split(',')#
      ims = Image.search_images_tags(t, 'and')#
      ims.uniq!
      ims = ims.where(site_name: site) if site
      ims = ims.limit(limit) if limit
      @image_array.push({images: ims, label: t[0]})
    end

    file_name = "#{site}_#{tag}#{DateTime.now}.zip"
    temp_file = Tempfile.new("#{file_name}-#{current_user.id}")


    Zip::OutputStream.open(temp_file.path) do |zos|
      zos.put_next_entry 'imagelist'
      zos.print IO.read(Image.create_list_file_labels(@image_array))

      @image_array.each_with_index do |images, i|
        images[:images].each do |image|
          # To avoid creating nested directory, remove slashes
          # E.g. 'NARUTO/xxx_zerochan.jpg' will create 'NARUTO' dir above the file in the zip
          title = image.get_title

          zos.put_next_entry(title)
          zos.print IO.read(image.data.path)
        end
      end
    end
    send_file temp_file.path, type: 'application/zip',
      disposition: 'attachment', filename: file_name
    temp_file.close
  end


  # [DEBUG] Download last 1000 images.
  def download_images_n
    limit = params[:limit]
    @images = Image.get_recent_n(limit)
    file_name = "user#{current_user.id}-#{DateTime.now}.zip"
    temp_file = Tempfile.new("#{file_name}-#{current_user.id}")

    Zip::OutputStream.open(temp_file.path) do |zos|
      zos.put_next_entry 'imagelist'
      zos.print IO.read(Image.create_list_file(@images))
      @images.each do |image|
        #title = "#{image.title}#{File.extname(image.data.path)}"
        # To avoid creating nested directory, remove slashes
        # E.g. 'NARUTO/xxx_zerochan.jpg' will create 'NARUTO' dir above the file in the zip
        #puts title = title.gsub!(/\//, '_') if title.include?("/")
        title = image.get_title
        puts title
        zos.put_next_entry(title)

        #puts image.data.path if image.site_name == 'zerochan'
        zos.print IO.read(image.data.path)
      end
    end
    send_file temp_file.path, type: 'application/zip',
      disposition: 'attachment', filename: file_name
    temp_file.close
  end

  def download_images_custom
    limit = params[:limit]
    start = params[:start]
    @image_array = Image.search_images_custom(limit, start)
    file_name = "user#{current_user.id}-#{DateTime.now}.zip"
    temp_file = Tempfile.new("#{file_name}-#{current_user.id}")

    Zip::OutputStream.open(temp_file.path) do |zos|
      zos.put_next_entry 'imagelist'
      zos.print IO.read(Image.create_list_file_labels(@image_array))

      titles = []
      @image_array.each_with_index do |images, i|
        images[:images].each do |image|
          title = image.get_title
          titles.push title

          # Detect duplication and rename the latest title for making extracting zip file be sucessful
          if titles.uniq.length != titles.length
            title += Random.rand(10000).to_s
          end

          zos.put_next_entry(title)
          zos.print IO.read(image.data.path)
        end
      end
      puts '=========================DEBUG'
      puts titles.uniq.length == titles.length

    end
    send_file temp_file.path, type: 'application/zip',
      disposition: 'attachment', filename: file_name
    temp_file.close
  end


  # The page for debugging illust detection feature.
  # イラスト判定ツールのデバッグ用ページを表示する。
  def debug_illust_detection
    # Get images first
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

  # Set @search variable to make ransack's search form work
  def set_search
    @search = Image.search(params[:q])
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
