require "#{Rails.root}/app/services/target_images_service"
require "#{Rails.root}/app/workers/target_images_face"

class TargetImagesController < ApplicationController
  before_filter :authenticate
  before_action :set_target_image, only: [:show, :edit, :update, :destroy, :show_delivered, :switch]

  # GET /target_images
  # GET /target_images.json
  def index
    @target_images = TargetImage.all.page(params[:page])
  end

  # GET /target_images/1
  # GET /target_images/1.json
  def show
  end

  # GET /target_images/new
  def new
    @target_image = TargetImage.new
  end

  # GET /target_images/1/edit
  def edit
  end

  # POST /target_images
  # POST /target_images.json
  def create
    @target_image = current_user.target_images.build(target_image_params)
    @target_image.enabled = true

    respond_to do |format|
      if @target_image.save
        # Execute face feature extraction process asynchronously via Resque
        #Resque.enqueue(TargetFace, @target_image.id)
        Resque.enqueue(ImageFeature, 'TargetImage', @target_image.id)

        format.html { redirect_to controller: 'users', action: 'show_target_images' }
        format.json { render action: 'show', status: :created, location: @target_image }
      else
        format.html { render action: 'new' }
        format.json { render json: @target_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /target_images/1
  # PATCH/PUT /target_images/1.json
  def update
    #hash = { data: params[:target_image][:data]}

    respond_to do |format|
      if @target_image.update(target_image_params)
      #if @target_image.update_attributes(hash)
        format.html { redirect_to controller: 'users', action: 'show_target_images' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @target_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /target_images/1
  # DELETE /target_images/1.json
  def destroy
    @target_image.destroy
    respond_to do |format|
      format.html { redirect_to show_target_images_users_path }
      format.json { head :no_content }
    end
  end

  def similar_convnet
    @target_image = TargetImage.find(params[:id])

=begin
    if target_image.feature == nil
      return @message = 'Not extracted yet.'
    elsif target_image.feature.face == '[]'
      return @message = 'Could not get face feature from this image.'
    end
=end

    similar = @target_image.get_similar_convnet_images()

    # Pagenate the array
    @similars = Kaminari.paginate_array(similar).page(params[:page]).per(50)
  end


  # Display images that have similar hair/eyes color based on face features
  # GET /target_images/1/prefer
  def prefer
    @preferred = []
    @message = ''
    target_image = TargetImage.find(params[:id])

    # If there are no correc features, redirect to index.
    # Return explicitly to skip the latter process.
    if target_image.feature == nil
      return @message = 'Not extracted yet.'
    elsif target_image.feature.face == '[]'
      return @message = 'Could not get face feature from this image.'
    end

    # Get preferred images array
    service = TargetImagesService.new
    result = service.get_preferred_images(target_image)
    @preferred = result[:images]
    @target_colors = result[:target_colors]
    @debug = result[:debug]

    # Pagenate the array
    @preferred = Kaminari.paginate_array(@preferred).page(params[:page]).per(100)
  end

  def show_delivered
    @delivered_images = @target_image.delivered_images.
      where('avoided IS NULL or avoided = false').page(params[:page]).per(25)
  end

  def switch
    enabled = @target_image.enabled ? false : true
    @target_image.update_attributes(enabled: enabled)
    redirect_to :back
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_target_image
      @target_image = TargetImage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def target_image_params
      params.require(:target_image).permit(:title, :data)
    end
end
