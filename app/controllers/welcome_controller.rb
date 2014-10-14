class WelcomeController < ApplicationController
  def index
    @images = Image.get_recent_images(15).page(params[:page]).per(15)
  end
end
