require 'rubygems'
require 'zip'

class UsersController < ApplicationController
  before_action :render_not_signed_in, only: [:show_favored_images]

  # GET
  # Render an user's home page.
  # ユーザ個別のホームページを表示する。
  def home
    return render action: 'not_signed_in' unless signed_in?
    session[:sort] = params[:sort] if params[:sort]

    # Get delivered_images
    if current_user.target_words.nil? or current_user.target_words.empty?
      delivered_images = Image.where("created_at>?", DateTime.now)
    else
      delivered_images = current_user.get_delivered_images
      delivered_images.reorder!('posted_at DESC') if params[:sort]

      # Filter delivered_images by date
      if params[:date]
        date = DateTime.parse(params[:date]).to_date
        delivered_images = User.filter_by_date(delivered_images, date)
      end
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

  # Render the index page of target_images.
  def show_target_images
    return render action: 'not_signed_in' unless signed_in?

    @target_images = current_user.target_images
    render action: 'show_target_images'
  end

  # Render the index page of target_words.
  def show_target_words
    return render action: 'not_signed_in' unless signed_in?

    @words = current_user.target_words
    render action: 'show_target_words'
  end

  # Render the list of clipped images.
  def show_favored_images
    board_id = params[:board]
    board = current_user.get_board(board_id)

    unless board.nil?
      session[:selected_board] = board.id
      @image_board = ImageBoard.find(board.id)
      @favored_images = board.favored_images.page(params[:page]).per(25)
    else
      render action: 'no_boards'
    end
  end

  # Remove a registered text tag from user.target_words.
  # 登録タグの削除：関連のみ削除する
  def delete_target_word
    current_user.target_words.delete(TargetWord.find(params[:id]))

    @words = current_user.target_words
    render action: 'show_target_words'
  end


  # An action for debug.
  # This feature will be deleted in the production version.
  # 画像のダウンロード：releaseする時にこの機能は削除する。
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


  # A page for debugging illust detection feature.
  # イラスト判定ツールのデバッグ用ページを表示する。
  def debug_illust_detection
    return redirect_to :back unless signed_in?

    update_session(params)

    # Get delivered_images
    if session[:all]
      delivered_images = current_user.get_delivered_images_all
    else
      delivered_images = current_user.get_delivered_images
    end

    # Filter by is_an_illustration value
    @debug = get_session_data
    delivered_images = User.filter_by_illust(delivered_images, session[:illust])

    # Sort delivered_images if any requests exist.
    delivered_images = User.sort_delivered_images(delivered_images, params[:page]) if session[:sort] == 'favorites'
    delivered_images = User.sort_by_quality(delivered_images, params[:page]) if session[:sort] == 'quality'

    @delivered_images = delivered_images.page(params[:page]).per(25)
  end


  private

  # Render the template if an user is not signed in.
  def render_not_signed_in
    render action: 'not_signed_in' unless signed_in?
  end

  # Update session values by request parameters.
  def update_session(params)
    session[:all] = (not session[:all]) if params[:toggle_site]
    session[:sort] = params[:sort] if params[:sort]
    session[:illust] ||= 'all'
    session[:illust] = params[:illust] if params[:illust]
  end


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
