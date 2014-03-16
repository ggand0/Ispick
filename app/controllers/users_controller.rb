require 'rubygems'
require 'zip'

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

  def show_target_words
    if signed_in?
      @words = current_user.target_words
      render action: 'show_target_words'
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

  def download_favored_images
    if signed_in?
      # クリップされた配信イラストを取得
      @images = current_user.delivered_images.where(favored: true)
      file_name  = "#{current_user.name}.zip"

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
    else
      redirect_to :back
    end
  end

end
