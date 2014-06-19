class FavoredImagesController < ApplicationController
  before_action :set_favored_image, only: [:show, :destroy]

  # GET /favored_images/1
  # GET /favored_images/1.json
  def show
    respond_to do |format|
      format.html
      format.js { render partial: 'show' }
    end
  end

  # DELETE /favored_images/1
  # DELETE /favored_images/1.json
  def destroy
    @favored_image.destroy
    respond_to do |format|
      format.html { redirect_to show_favored_images_users_path }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_favored_image
      @favored_image = FavoredImage.find(params[:id])
    end
end
