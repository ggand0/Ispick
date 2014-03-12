class UsersController < ApplicationController
  def home
    if signed_in?
      @images = current_user.delivered_images
      render :action => 'signed_in'
    else
      render :action => 'not_signed_in'
    end
  end

end
