class UsersController < ApplicationController
  def home
    if signed_in?
      # paginationについては調整中。数が固定されたらモデルに表示数を定義する
      @images = current_user.delivered_images.page(params[:page]).per(25)
      render action: 'signed_in'
    else
      render action: 'not_signed_in'
    end
  end

  def show_target_images
    if signed_in?
      @images = current_user.target_images
      render action: 'show_target_images'
    else
      render action: 'not_signed_in'
    end
  end

  def show_favored_images
    if signed_in?
      @images = current_user.delivered_images.where(favored: true).page(params[:page]).per(25)
      render action: 'show_favored_images'
    else
      render action: 'not_signed_in'
    end
  end

end
