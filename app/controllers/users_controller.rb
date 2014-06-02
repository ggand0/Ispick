require 'rubygems'
require 'zip'

class UsersController < ApplicationController
  def home
    if signed_in?
      delivered_images = current_user.delivered_images.where.not(images: { site_name: 'twitter' }).
        joins(:image).order('images.posted_at')

      # 配信日で絞り込む場合
      if params[:date]
        date = params[:date]
        date = DateTime.parse(date).to_date
        delivered_images = delivered_images.where(created_at: date.to_datetime.utc..(date+1).to_datetime.utc)
      end

      @delivered_images = delivered_images.page(params[:page]).per(25)
      @delivered_images_all = delivered_images
      render action: 'signed_in'
    else
      render action: 'not_signed_in'
    end
  end

  def sort_delivered_images(delivered_images)
    delivered_images = delivered_images.includes(:image).
      reorder('images.favorites desc').references(:images)
    delivered_images.page(params[:page]).per(25)
  end
  def sort_by_quality(delivered_images)
    delivered_images = delivered_images.includes(:image).
      reorder('images.quality desc').references(:images)
    delivered_images.page(params[:page]).per(25)
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


  # デバッグ用
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

  # デバッグ用
  def debug_illust_detection
    if signed_in?
      session[:all] = (not session[:all]) if params[:toggle_site]
      session[:sort] = params[:sort]

      if session[:all]
        delivered_images = current_user.delivered_images.
          joins(:image).order('images.posted_at')
      else
        delivered_images = current_user.delivered_images.where(images: { site_name: 'twitter' }).
          joins(:image).order('images.posted_at')
      end

      # イラスト判定リクエストがある場合：
      delivered_images = delivered_images.includes(:image).
        where(images: { is_illust: true }).references(:images) if params[:illust]

      # ソートリクエストがある場合：
      delivered_images = sort_delivered_images delivered_images if session[:sort] == 'favorites'
      delivered_images = sort_by_quality delivered_images if session[:sort] == 'quality'

      @delivered_images = delivered_images.page(params[:page]).per(25)
    else
      render action: 'not_signed_in'
    end
  end

  private
  def filter_illust(delivered_images, filter)
    case filter
    when 'all'
      return delivered_images
    when 'illust'
      return delivered_images.includes(:image).
        where(images: { is_illust: true }).references(:images)
    when 'photo'
      return delivered_images.includes(:image).
        where(images: { is_illust: false }).references(:images)
  end

end
