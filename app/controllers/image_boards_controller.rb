class ImageBoardsController < ApplicationController
  before_action :set_image_board, only: [:show, :edit, :update, :destroy]

  # GET /image_boards
  # GET /image_boards.json
  def index
    @image_boards = ImageBoard.all
  end

  # GET /image_boards/1
  # GET /image_boards/1.json
  def show
  end

  # GET /image_boards/new
  def new
    @image_board = ImageBoard.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def boards
    #puts current_user.image_boards.count
    ImageBoard.connection.clear_query_cache
    puts @id = params[:id]
    @image = DeliveredImage.find(params[:image])
    @board = ImageBoard.new
    respond_to do |format|
      format.html { render partial: 'shared/popover_board', locals: { image: @image, image_board: @board, html: @id } }
      format.js { render partial: 'boards' }  # => _boards.js.erbを描画
    end
  end

  def reload
    @image = DeliveredImage.find(params[:image])
    @board = ImageBoard.new
    respond_to do |format|
      format.html
      format.js { render partial: 'reload' }
    end
  end

  # paramsで指定されたdelivered_imageが
  # image_boardに既に登録されているか確認する
  def check_existed
    delivered_image = DeliveredImage.find(params[:image])

    included = @image_board.favored_images.include? do |f|
      f.delivered_image.id == delivered_image.id
    end

    render json: { exist: included }
  end

  # GET /image_boards/1/edit
  def edit
  end

  # POST /image_boards
  def create
    @image_board = ImageBoard.new(image_board_params)
    @image_board.save!
    current_user.image_boards << @image_board

    render nothing: true
  end

  # PATCH/PUT /image_boards/1
  # PATCH/PUT /image_boards/1.json
  def update
    respond_to do |format|
      if @image_board.update(image_board_params)
        format.html { redirect_to @image_board, notice: 'Image board was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @image_board.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /image_boards/1
  # DELETE /image_boards/1.json
  def destroy
    @image_board.destroy
    respond_to do |format|
      format.html { redirect_to image_boards_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image_board
      @image_board = ImageBoard.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_board_params
      params.require(:image_board).permit(:name)
    end
end
