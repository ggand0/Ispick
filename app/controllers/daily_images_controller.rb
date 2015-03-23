class DailyImagesController < ApplicationController
  def rss
    display_num = current_user ? current_user.display_num : User::DEFAULT_DISPLAY_NUM
    ids = DailyImage.all.map{ |i| i.image_id }
    @images = Image.where('id in (?)', ids)
    .page(params[:page]).per(display_num)
    @count = @images.count
    @pagination = current_user ? current_user.pagination : false

    respond_to do |format|
      format.html {}
      format.js {}
      format.rss { render :layout => false }
    end
  end

end
