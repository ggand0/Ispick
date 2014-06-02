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
  end

  # GET /image_boards/1/edit
  def edit
  end

  # POST /image_boards
  # POST /image_boards.json
  def create
    @image_board = ImageBoard.new(image_board_params)

    respond_to do |format|
      if @image_board.save
        format.html { redirect_to @image_board, notice: 'Image board was successfully created.' }
        format.json { render action: 'show', status: :created, location: @image_board }
      else
        format.html { render action: 'new' }
        format.json { render json: @image_board.errors, status: :unprocessable_entity }
      end
    end
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
      params[:image_board]
    end
end
