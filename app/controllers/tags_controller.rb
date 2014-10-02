class TagsController < ApplicationController
  before_action :set_tag, only: [:images, :attach]

  # POST
  # This action only get the existing TargetWord record,
  # and add it to current_user.target_words.
  def attach
    current_user.tags << @tag

    respond_to do |format|
      format.html { redirect_to controller: 'users', action: 'preferences' }
      format.js { @tags = current_user.tags; render partial: 'layouts/reload_followed_tags' }
    end
  end


  # Show images associated by a specific tag. Will be moved to the UsersController class.
  # 特定のタグに配信されている画像のみを表示する。UsersControllerに移動予定
  def images
    redirect_to '/signin_with_password' unless signed_in?

    # Get images of the TargetWord record
    images = @tag.get_images

    # Filter by created_at attribute
    # 配信日で絞り込む場合
    if params[:date]
      date = params[:date]
      date = DateTime.parse(date).to_date
      images = Image.filter_by_date(images, date)
    end

    @images = images.page(params[:page]).per(25)
    @images_all = images
    render action: 'home'
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
