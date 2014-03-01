class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit, :update, :destroy]

  # GET /images
  # GET /images.json
  def index
    @images = Image.all.page(params[:page])
  end

  # GET /images/1
  # GET /images/1.json
  def show
    @image = Image.find(params[:id])
    if @image.feature.nil?
      @face_feature = 'Not extracted.'
    else
      @face_feature = @image.feature.face
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    end
end
