require 'rubygems'
require 'zip'

class UsersController < ApplicationController
  before_action :render_not_signed_in, only: [:show_favored_images]

  def home
    return render action: 'not_signed_in' unless signed_in?
    session[:sort] = params[:sort] if params[:sort]

    # Get delivered_images
    delivered_images = current_user.get_delivered_images
    delivered_images.reorder!('posted_at DESC') if params[:sort]

    # Filter delivered_images by date
    if params[:date]
      date = DateTime.parse(params[:date]).to_date
      delivered_images = User.filter_by_date(delivered_images, date)
    end

    @delivered_images = delivered_images.page(params[:page]).per(25)
    @delivered_images_all = delivered_images
    render action: 'signed_in'
  end

  # GET
  def new_avatar
    respond_to do |format|
      format.html
      format.js { render partial: 'new_avatar' }
    end
  end

  # POST
  def create_avatar
    session[:return_to] ||= request.referer

    user = User.find(params[:id])
    user.avatar = params[:avatar]
    user.save!

    respond_to do |format|
      format.html { redirect_to session.delete(:return_to) }
      format.js { render nothing: true }
    end
  end

  def show_target_images
    return render action: 'not_signed_in' unless signed_in?

    @target_images = current_user.target_images
    render action: 'show_target_images'
  end

  def show_target_words
    return render action: 'not_signed_in' unless signed_in?

    @words = current_user.target_words
    render action: 'show_target_words'
  end

  # 登録タグの削除：関連のみ削除する
  def delete_target_word
    current_user.target_words.delete(TargetWord.find(params[:id]))

    @words = current_user.target_words
    render action: 'show_target_words'
  end

  def show_favored_images
    board_id = params[:board]
    board = get_board(board_id)

    unless board.nil?
      session[:selected_board] = board.id
      @image_board = ImageBoard.find(board.id)
      @favored_images = board.favored_images.page(params[:page]).per(25)
    else
      render action: 'no_boards'
    end
  end


  # A function for debug
  # This feature will be deleted in the production
  def download_favored_images
    return redirect_to :back unless signed_in?

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
                              disposition: 'attachment',
                              filename: file_name
    temp_file.close
  end


  # A page for debug
  def debug_illust_detection
    return redirect_to :back unless signed_in?

    update_session(params)

    if session[:all]
      delivered_images = current_user.delivered_images.
        joins(:image).order('images.posted_at')
    else
      delivered_images = current_user.delivered_images.where(images: { site_name: 'twitter' }).
        joins(:image).order('images.posted_at')
    end

    # Filter by is_an_illustration value
    @debug = get_session_data
    delivered_images = filter_illust(delivered_images)

    # Sort delivered_images if any requests exist.
    delivered_images = User.sort_delivered_images(delivered_images) if session[:sort] == 'favorites'
    delivered_images = User.sort_by_quality(delivered_images) if session[:sort] == 'quality'

    @delivered_images = delivered_images.page(params[:page]).per(25)
  end


  private

  def render_not_signed_in
    render action: 'not_signed_in' unless signed_in?
  end

  def update_session(params)
    session[:all] = (not session[:all]) if params[:toggle_site]
    session[:sort] = params[:sort] if params[:sort]
    session[:illust] ||= 'all'
    session[:illust] = params[:illust] if params[:illust]
  end

  def filter_illust(delivered_images)
    case session[:illust]
    when 'all'
      return delivered_images
    when 'illust'
      return delivered_images.includes(:image).
        where(images: { is_illust: true }).references(:images)
    when 'photo'
      return delivered_images.includes(:image).
        where(images: { is_illust: false }).references(:images)
    end
  end

  def get_board(board_id)
    if board_id.nil?
      board = current_user.image_boards.first
    else
      board = current_user.image_boards.find(board_id)
    end
  end

  def get_session_data
    [
      "filter_illust: #{session[:illust]}",
      "sort_type: #{session[:sort]}",
      "filter_site: #{session[:all]}",
    ]
  end

end
