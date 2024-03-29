require 'rubygems'
require 'zip'

class UsersController < ApplicationController
  include ApplicationHelper
  before_filter :set_search
  before_filter :set_user, only: [:edit, :update, :settings, :preferences, :update_display_settings]
  before_filter :validate_authorization_for_user, only: [:edit, :update, :settings]
  before_filter :authenticate, only: [:show_target_images]

  before_action :render_sign_in_page,
    only: [:home, :boards, :preferences, :search, :show_target_images,
      :download_favored_images, :debug_illust_detection, :debug_crawling]
  before_action :update_session, only: [:home, :search]


  # GET /users/1/edit
  def edit
    render action: 'debug/edit'
  end
  # PUT /users/1
  def update
    if @user.update_attributes(user_params)
      flash[:success] = 'The user setting was successfully updated.'
      redirect_to settings_users_path(id: @user.id)
    else
      render action: 'debug/edit'
    end
  end

  # PUT /users/1
  def update_display_settings
    if @user.update_attributes(user_params)
      flash[:success] = 'The display setting was successfully updated.'
      respond_to do |format|
        format.html { redirect_to preferences_users_path(id: @user.id) }
        format.js { render partial: 'users/reload_displaying_fields' }
      end
    else
      redirect_to preferences_users_path(id: @user.id)
    end
  end


  # GET /users/1/settings
  def settings
  end


  # GET /users/home
  # Render an user's home page.
  def home
    if current_user.tags.empty?
      # Get images: For a new user, display the newer images
      images = Image.get_recent_images(500)
    else
      # Otherwise, display images from user.tags relation
      images = current_user.get_images
      images.reorder!('posted_at DESC') if params[:sort]
      images.reorder!('original_favorite_count DESC') if params[:fav]
    end
    images.uniq!

    # Filter images by date if neccesary
    if params[:date]
      date = DateTime.parse(params[:date]).to_date
      images = Image.filter_by_date(images, date)
    end

    # Filter images by sites
    #if params[:site]
    #  images = Image.filter_by_date(images, params[:site])
    #end

    images = images.where("site_name IN (?)", convert_sites(current_user.target_sites))
    @images = images.page(params[:page]).per(current_user.display_num)
    @count = images.select('images.id').count
    @pagination = current_user ? current_user.pagination : false
    @disable_fotter = true
  end

  def convert_sites(sites)
    result = []
    sites = sites.map{ |site| site.name }
    Image::TARGET_SITES_DISPLAY.each_with_index do |site, count|
      if sites.include? site
        result.push Image::TARGET_SITES[count]
      end
    end
    result
  end


  # GET /users/rss
  # Render streams of crawled websites.
  def rss
    # Filter images by sites
    if params[:site]
      images = Image.where(site_name: params[:site])
      @site = params[:site_name]
    else
      images = Image.where(site_name: 'anipic')
      @site = 'anime-pictures'
    end
    images = images.where.not(data_updated_at: nil).limit(1000)
    images.reorder!('posted_at DESC') if params[:sort]
    images.reorder!('original_favorite_count DESC') if params[:fav]
    images.uniq!

    display_num = current_user ? current_user.display_num : User::DEFAULT_DISPLAY_NUM
    @pagination = current_user ? current_user.pagination : false
    @images = images.page(params[:page]).per(display_num)
    @count = images.select('images.id').count
    @disable_fotter = true

    respond_to do |format|
      format.html {}
      format.js { render action: 'home' }
    end
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


  # Render the index page of tags.
  def preferences
    flash = nil
    puts flash.present?

    if params[:target_words]
      @popular_tags = TargetWord.get_tags_with_images(100).
        map { |target_word| Tag.where(name: target_word.name_english).first }
      @popular_tags.compact!
    else
      @popular_tags = Tag.get_tags_with_images(100)
    end
    @tags = current_user.tags
    @tag = Tag.new

    @search_tags = Tag.search(params[:q])
    if params[:q]
      @tags_result = @search_tags.result(distinct: true).page(params[:page]).per(50)
    end

    respond_to do |format|
      format.html { render action: 'preferences' }
      format.js { render partial: 'layouts/reload_popular_tags' }
    end
  end


  # Render the list of clipped images.
  def boards
    board_id = params[:board]
    board = current_user.get_board(board_id)

    unless board.nil?
      session[:selected_board] = board.id
      @image_board = ImageBoard.find(board.id)
      @pagination = current_user ? current_user.pagination : false
      display_num = current_user ? current_user.display_num : User::DEFAULT_DISPLAY_NUM
      @favored_images = board.favored_images.page(params[:page]).per(display_num)
      @total_size = bytes_to_megabytes(@image_board.get_total_size)
      @disable_fotter = true
    else
      render action: 'boards_no_images'
    end
  end

  # Remove a registered text tag from user.tags.
  # Only remove an association.
  def delete_target_word
    current_user.tags.delete(TargetWord.find(params[:id]))
    @tags = current_user.tags

    respond_to do |format|
      format.html { render action: 'preferences' }
      format.js { render partial: 'layouts/reload_followed_tags' }
    end
  end

  # Remove a registered text tag from user.tags.
  # Only remove an association.
  def delete_tag
    current_user.tags.delete(Tag.find(params[:id]))
    @tags = current_user.tags

    respond_to do |format|
      format.html { render action: 'preferences' }
      format.js { render partial: 'layouts/reload_followed_tags' }
    end
  end

  # GET
  # Show recommended_tags, mainly for debugging
  def recommended_tags
    @tags = current_user.recommended_tags
    @tags = @tags.order('cooccurrence_count desc')
    # Get images_count from an associated Tag object since RecommendedTag doesn't have any counter caches
    #@counts = current_user.recommended_tags.map { |t| t.tag.images_count }
  end

  # POST
  # Set User.sites after clearing it
  def set_sites
    current_user.target_sites.clear
    @sites = []

    TargetSite.all.each do |site|
      # Convert string to symbol
      if params[site.name.parameterize.underscore.to_sym].to_i == 1
        @sites.push site.name
      end
    end

    @sites.each do |site|
      current_user.target_sites << TargetSite.where(name: site).first
    end

    flash[:success] = 'The site settings was successfully updated.'
    respond_to do |format|
      format.html { redirect_to action: 'preferences' }
      format.js { render partial: 'users/reload_target_sites_fields' }
    end
  end


  # ===============================
  #  Debugging / temporary actions
  # ===============================
  # [Unused] Render the index page of target_images.
  def show_target_images
    @target_images = current_user.target_images
    render partial: 'debug/show_target_images'
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(current_user.id)
  end

  # Set @search variable to make ransack's search form work
  def set_search
    @search = Image.search(params[:q])
  end

  def user_params
    params.require(:user).permit(:name, :pagination, :display_num, :language, :language_preferences)
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

end
