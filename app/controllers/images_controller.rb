class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit, :update, :destroy, :favor, :hide]

  # GET /images
  # GET /images.json
  def index
    @images = Image.all.page(params[:page])
  end

  # GET /images/1
  # GET /images/1.json
  def show
    respond_to do |format|
      format.html
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
    puts "===============#{@image}"
    #@image.update_attributes!(favored: true) unless @image.favored

    # FavoredImageオブジェクト作成
    # src_urlが重複していた場合はvalidationでfalseが返る
    #image = @image
    board = current_user.image_boards.where(name: board_name).first
    favored_image = board.favored_images.build(
      title: @image.title,
      caption: @image.caption,
      data: @image.data,
      src_url: @image.src_url
    )

    # save出来たらimageへの参照も追加
    if favored_image.save
      @image.favored_images << favored_image
    end

    # format.jsの場合はpopoverをリロードするために'boards' templateを呼ぶ
    #@image = @image
    @board = ImageBoard.new
    @id = params[:html_id]
    respond_to do |format|
      format.html { redirect_to show_favored_images_users_path }
      format.js { render partial: 'image_boards/boards' }
    end
  end

  # PUT avoid
  def hide
    if not @image.avoided
      @image.update_attributes!(avoided: true)
    else
      @image.update_attributes!(avoided: false)
    end
    redirect_to :back
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    end
end
