class TagsController < ApplicationController
  before_action :set_tag, only: [:images, :attach, :follow_remote]

  # POST
  # This action only get the existing TargetWord record,
  # and add it to current_user.target_words.
  def attach
    current_user.tags << @tag

    respond_to do |format|
      format.html { redirect_to controller: 'users', action: 'preferences' }
      format.js do
        @tags = current_user.tags
        render partial: 'shared/reload_notice'
      end
    end
  end
  # POST
  # Same as the above one, but this is called from the detail view.
  def follow_remote
    current_user.tags << @tag
    flash[:success] = 'You\'ve followed a new tag!'

    respond_to do |format|
      format.js do
        @tags = current_user.tags
        render partial: 'shared/reload_notice'
      end
    end
  end

  # GET
  # Show images associated by a specific tag.
  def images
    redirect_to '/signin_with_password' unless signed_in?

    # Get images of the TargetWord record
    images = @tag.get_images
    images.reorder!('posted_at DESC') if params[:sort]
    images.reorder!('original_favorite_count DESC') if params[:fav]

    # Filter by created_at attribute
    if params[:date]
      date = params[:date]
      date = DateTime.parse(date).to_date
      images = Image.filter_by_date(images, date)
    end

    # Filter images by sites
    if params[:site]
      images = Image.filter_by_date(images, params[:site])
    end

    @pagination = current_user ? current_user.pagination : false
    @images = images.page(params[:page]).per(current_user.display_num)
    @count = images.select('images.id').count
    @disable_fotter = true

    respond_to do |format|
      format.html { render action: 'home' }
      format.js { render action: 'home' }
      format.rss { render action: 'tag_images' }
    end
  end


  def autocomplete
    @tags = Tag.order(:name).where("images_count > (?)", 1).where("name LIKE ?", "%#{params[:term]}%")
    respond_to do |format|
      format.html
      format.json {
        render json: @tags.map(&:name)
      }
    end
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_tag
    @tag = Tag.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def tag_params
    params.require(:tag).permit(:name, :id)
  end
end
