class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit, :update, :destroy, :favor, :favor_another, :hide, :show_debug]

  # GET /images
  # GET /images.json
  def index
    @images = Image.all.page(params[:page])
  end

  # GET /images/1
  # GET /images/1.json
  def show
    respond_to do |format|
      format.html {}
      format.js { render partial: 'show' }
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.destroy
    respond_to do |format|
      format.html { redirect_to images_url }
      format.json { head :no_content }
    end
  end


  # PUT favor
  # imageをお気に入り画像として追加する。
  def favor
    board_name = params[:board]

    # FavoredImageオブジェクト作成
    # src_urlが重複していた場合はvalidationでfalseが返る
    # Board名のリンクをクリックして呼ばれるので必ず対応するboardがあると仮定
    board = current_user.image_boards.where(name: board_name).first
    favored_image = board.favored_images.build(
      title: @image.title,
      caption: @image.caption,
      data: @image.data,
      src_url: @image.src_url,
      page_url: @image.page_url,
      site_name: @image.site_name,
      views: @image.views,
      favorites: @image.favorites,
      posted_at: @image.posted_at,
    )

    # save出来たらimageへの参照も追加
    if favored_image.save
      @image.favored_images << favored_image
    end

    # format.jsの場合はpopoverをリロードするために'boards' templateを呼ぶ
    @clipped_board = board_name
    @board = ImageBoard.new
    @id = params[:html_id]
    respond_to do |format|
      format.html { redirect_to boards_users_path }
      #format.js { render partial: 'image_boards/boards' }
      format.js { render partial: 'image_boards/after_clipped' }
    end
  end

  # PUT hide
  def hide
    if not @image.avoided
      @image.update_attributes!(avoided: true)
    else
      @image.update_attributes!(avoided: false)
    end
    redirect_to :back
  end



  # =======
  #  DEBUG
  # =======
  def favor_another
    board_name = params[:board]
    board = current_user.image_boards.where(name: board_name).first
    favored_image = board.favored_images.build(
      title: @image.title,
      caption: @image.caption,
      data: @image.data,
      src_url: @image.src_url,
      page_url: @image.page_url,
      site_name: @image.site_name,
      views: @image.views,
      favorites: @image.favorites,
      posted_at: @image.posted_at,
    )
    if favored_image.save
      @image.favored_images << favored_image
    end
    @clipped_board = board_name
    @board = ImageBoard.new
    @id = params[:html_id]
    respond_to do |format|
      format.html { redirect_to boards_users_path }
      format.js { render partial: 'image_boards/boards_another' }
    end
  end

  def show_debug
    respond_to do |format|
      format.js { render partial: 'show_image_debug' }
      #format.js { render partial: 'show' }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    end
end
