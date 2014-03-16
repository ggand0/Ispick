class DeliveredImagesController < ApplicationController
  before_action :set_delivered_image, only: [:show, :edit, :update, :destroy, :favor]

  # GET /delivered_images
  # GET /delivered_images.json
  def index
    @delivered_images = DeliveredImage.all
  end

  # GET /delivered_images/1
  # GET /delivered_images/1.json
  def show
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
  def favor
    if not @delivered_image.favored
      @delivered_image.update_attributes!(favored: true)
    else
      @delivered_image.update_attributes!(favored: false)
    end

    # そのうちAjax callするようにする
    #redirect_to :back
    render nothing: true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delivered_image
      @delivered_image = DeliveredImage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def delivered_image_params
      params.require(:delivered_image).permit(:title, :caption, :src_url)
    end
end
