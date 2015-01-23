class DailyImagesController < ApplicationController
  def rss
    @images = DailyImage.all

    respond_to do |format|
      format.html { render nothing: true }
      format.rss { render :layout => false }
    end
  end

end
