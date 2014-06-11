class DeliveredImagesController < ApplicationController
  before_action :set_delivered_image, only: [:show, :edit, :update, :destroy, :favor, :avoid]

  # GET /delivered_images
  # GET /delivered_images.json
  def index
    @delivered_images = DeliveredImage.all
  end

  # GET /delivered_images/1
  # GET /delivered_images/1.json
  def show
    respond_to do |format|
      format.html
      format.js { render partial: 'show' }
    end
  end

  # GET /delivered_images/new
  def new
    @delivered_image = DeliveredImage.new
  end

  # GET /delivered_images/1/edit
  def edit
  end

  # POST /delivered_images
  # POST /delivered_images.json
  def create
    @delivered_image = DeliveredImage.new(delivered_image_params)

    respond_to do |format|
      if @delivered_image.save
        format.html { redirect_to @delivered_image, notice: 'Delivered image was successfully created.' }
        format.json { render action: 'show', status: :created, location: @delivered_image }
      else
        format.html { render action: 'new' }
        format.json { render json: @delivered_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /delivered_images/1
  # PATCH/PUT /delivered_images/1.json
  def update
    respond_to do |format|
      if @delivered_image.update(delivered_image_params)
        format.html { redirect_to @delivered_image, notice: 'Delivered image was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @delivered_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /delivered_images/1
  # DELETE /delivered_images/1.json
  def destroy
    @delivered_image.destroy
    respond_to do |format|
      format.html { redirect_to delivered_images_url }
      format.json { head :no_content }
    end
  end

  # PUT favor
  # delivered_imageをお気に入り画像として追加する。
  # Ajax callで呼ばれることを想定
  def favor
    board_name = params[:board]
    @delivered_image.update_attributes!(favored: true) unless @delivered_image.favored

    # FavoredImageオブジェクト作成
    # src_urlが重複していた場合はvalidationでfalseが返る
    image = @delivered_image.image
    board = current_user.image_boards.where(name: board_name).first
    favored_image = board.favored_images.build(
      title: image.title,
      caption: image.caption,
      data: image.data,
      src_url: image.src_url
    )

    # save出来たらdelivered_imageへの参照も追加
    favored_image.delivered_image = @delivered_image if favored_image.save

    # favoredが変更された結果を返す
    if params[:render] == 'true'
      # そのdelivered_imageがfavoredされているかどうかを返す
      render text: @delivered_image.favored_image != nil
    else
      redirect_to show_favored_images_users_path
    end

  end

  # PUT avoid
  def avoid
    if not @delivered_image.avoided
      @delivered_image.update_attributes!(avoided: true)
    else
      @delivered_image.update_attributes!(avoided: false)
    end
    redirect_to :back
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delivered_image
      @delivered_image = DeliveredImage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def delivered_image_params
      params.require(:delivered_image).permit(:avoided)
    end
end
