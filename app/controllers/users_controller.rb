require 'rubygems'
require 'zip'

class UsersController < ApplicationController
  def home
    if signed_in?
      # paginationについては調整中。数が固定されたらモデルに表示数を定義する
      if params[:year] and params[:month] and params[:day]
        date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i).to_datetime
      else
        date = Date.today.to_datetime
      end

      # その日員配信されたdelivered_imagesに限定する
      start_day = date.change(offset: '+0900')
      end_day = (date+1).change(offset: '+0900')

      delivered_images = current_user.delivered_images.
        where('avoided IS NULL or avoided = false').
        where(created_at: start_day.utc..end_day.utc)

      # イラスト判定リクエストがある場合：
      delivered_images = delivered_images.includes(:image).
        where(images: { is_illust: true }).references(:images) if params[:illust]

      # ソートリクエストがある場合：
      delivered_images = delivered_images.reorder('favorites desc') if params[:sort]

      @delivered_images = delivered_images.page(params[:page]).per(25)
      render action: 'signed_in'
    else
      render action: 'not_signed_in'
    end
  end

  def sort_delivered_images
    if signed_in?
      delivered_images = current_user.delivered_images.reorder('favorites desc')
      @delivered_images = delivered_images.page(params[:page]).per(25)
      render action: 'signed_in'
    else
      render action: 'not_signed_in'
    end
  end

  def show_illusts
    if signed_in?
      # paginationについては調整中。数が固定されたらモデルに表示数を定義する
      delivered_images = current_user.delivered_images.
        includes(:image).
        where('avoided IS NULL or avoided = false').
        where('images.is_illust=?', true).
        references(:images)
      #delivered_images = current_user.delivered_images.joins(:image).merge(Image.where(is_illust: true))

      @delivered_images = delivered_images.page(params[:page]).per(25)
      render action: 'signed_in'
    else
      render action: 'not_signed_in'
    end
  end


  def show_target_images
    if signed_in?
      @target_images = current_user.target_images
      render action: 'show_target_images'
    else
      render action: 'not_signed_in'
    end
  end

  def show_target_words
    # Test commit
    if signed_in?
      @words = current_user.target_words
      render action: 'show_target_words'
    else
      render action: 'not_signed_in'
    end
  end

  def show_favored_images
    if signed_in?
      # favored_imagesを表示するようにする
      @images = current_user.favored_images.page(params[:page]).per(25)
      render action: 'show_favored_images'
    else
      render action: 'not_signed_in'
    end
  end

  def download_favored_images
    if signed_in?
      @images = current_user.favored_images
      file_name  = "user#{current_user.id}-#{DateTime.now}.zip"

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
