require 'rubygems'
require 'zip'
require "#{Rails.root}/script/scrape/scrape_tumblr"

class UsersController < ApplicationController
  include ApplicationHelper
  before_filter :set_user, only: [:edit, :update, :settings]
  before_filter :validate_authorization_for_user, only: [:edit, :update, :settings]

  before_action :render_sign_in_page,
    only: [:home, :boards, :preferences, :search, :show_target_images,
      :download_favored_images, :debug_illust_detection, :debug_crawling]
  before_action :update_session, only: [:home, :search, :debug_illust_detection]

  # GET /users/1/edit
  def edit
    render action: 'debug/edit'
  end
  # PUT /users/1
  def update
    if @user.update_attributes(user_params)
      redirect_to settings_users_path(id: @user.id), notice: 'the settings was successfully updated.'
    else
      render action: 'debug/edit'
    end
  end

  # GET /users/1/settings
  def settings
  end


  # GET /users/home
  # Render an user's home page.
  # ユーザ個別のホームページを表示する。
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

  # GET
  def search
    images = Image.search_images(params[:query])
    images.reorder!('posted_at DESC') if params[:sort]

    # Filter images by date
    if params[:date]
      date = DateTime.parse(params[:date]).to_date
      images = Image.filter_by_date(images, date)
    end

    @images = images.page(params[:page]).per(25)
    @images_all = images
    render action: 'home'
  end

  # GET
  def new_avatar
    respond_to do |format|
      format.html {}
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

  # [Unused]画像登録画面を表示する
  # Render the index page of target_images.
  def show_target_images
  @target_images = current_user.target_images
    render action: 'debug/show_target_images'
  end

  # タグ登録画面を表示する
  # Render the index page of target_words.
  def preferences
    @popular_tags = TargetWord.get_tags_with_images(20)
    @target_words = current_user.target_words
    @target_word = TargetWord.new
    @search = Person.search(params[:q])
    @people = @search.result(distinct: true).page(params[:page]).per(50)

    respond_to do |format|
      format.html { render action: 'preferences' }
      format.js { render partial: 'layouts/reload_popular_tags' }
    end
  end

  # お気に入り画像一覧ページを表示する
  # Render the list of clipped images.
  def boards
    board_id = params[:board]
    board = current_user.get_board(board_id)

    unless board.nil?
      session[:selected_board] = board.id
      @image_board = ImageBoard.find(board.id)
      @favored_images = board.favored_images.page(params[:page]).per(25)
      @total_size = bytes_to_megabytes(@image_board.get_total_size)
    else
      render action: 'boards_no_images'
    end
  end

  # 登録タグの削除：関連のみ削除する
  # Remove a registered text tag from user.target_words.
  def delete_target_word
    current_user.target_words.delete(TargetWord.find(params[:id]))
    @target_words = current_user.target_words

    respond_to do |format|
      format.html { render action: 'preferences' }
      format.js { render partial: 'layouts/reload_followed_tags' }
    end
  end

  # A temporary method. Will be fixed.
  def share_tumblr
    if current_user.provider == 'tumblr'
      ::Tumblr.configure do |config|
        config.oauth_token = session[:oauth_token]
        config.oauth_token_secret = session[:oauth_token_secret]
      end
      client = ::Tumblr::Client.new
      image = Image.find(params[:image_id])
      #client.photo("http://anime-cute-girls.tumblr.com/", {:data => ['/path/to/pic.jpg', '/path/to/pic.jpg']})
      client.photo("anime-cute-girls.tumblr.com", {:data => [image.data.path]})
    end

    redirect_to home_users_path
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :language, :language_preferences)
  end

  def validate_authorization_for_user
    redirect_to root_path unless @user == current_user
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
