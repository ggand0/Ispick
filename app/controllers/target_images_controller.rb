require "#{Rails.root}/app/services/target_images_service"

class TargetImagesController < ApplicationController
  before_action :set_target_image, only: [:show, :edit, :update, :destroy]

  # GET /target_images
  # GET /target_images.json
  def index
    @target_images = TargetImage.all
  end

  # GET /target_images/1
  # GET /target_images/1.json
  def show
    @target_image = TargetImage.find(params[:id])
    @face_feature = JSON.parse(@target_image.face_feature)
  end

  # GET /target_images/new
  def new
    @target_image = TargetImage.new
  end

  # GET /target_images/1/edit
  def edit
    #@target_image = TargetImage.find(params[:id])
  end

  # POST /target_images
  # POST /target_images.json
  def create
    #target_image_params # titleのみのhash
    @target_image = TargetImage.new(title: params[:target_image][:title], data: params[:target_image][:data])

    respond_to do |format|
      if @target_image.save
        # 顔の特徴量を抽出する
        service = TargetImagesService.new
        face_feature = service.prefer(@target_image)
        json_string = face_feature[:result].to_json
        @target_image.update_attributes({ face_feature: json_string })

        format.html { redirect_to @target_image, notice: 'Target image was successfully created.' }
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
    target = TargetImage.find(params[:id])
    hash = { title: params[:target_image][:title], data: params[:target_image][:data]}
    h = { title: params[:target_image][:title] }

    respond_to do |format|
      #if @target_image.update(target_image_params)
      if @target_image.update_attributes(hash)
      #if target.update_attributes(hash)
      #if @target_image.update_attributes(title: params[:target_image][:title], data: params[:target_image][:data])
        format.html { redirect_to @target_image, notice: 'Target image was successfully updated.' }
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
      format.html { redirect_to target_images_url }
      format.json { head :no_content }
    end
  end


  # 顔の特徴量を抽出して、処理時間とともにJSON形式で表示する
  # 顔の特徴量をもとに、髪・目の色が似てる画像一覧を表示する
  def prefer
    #service = TargetImagesService.new
    #result = service.prefer(TargetImage.find(params[:id]))
    #render json: result

    preferred = []
    target_image = TargetImage.find(params[:id])
    face_feature = JSON.parse(target_image.face_feature)
    #render text: face_feature[0]['hair_color']
    target_r = face_feature[0]['hair_color']['red'].to_i
    target_g = face_feature[0]['hair_color']['green'].to_i
    target_b = face_feature[0]['hair_color']['blue'].to_i

    Image.all.each do |image|
      if image.face_feature == '[]'
        next
      end

      image_face = JSON.parse(image.face_feature)
      r = image_face[0]['hair_color']['red'].to_i
      g = image_face[0]['hair_color']['green'].to_i
      b = image_face[0]['hair_color']['blue'].to_i

      #if (target_r - r).abs < 50 and (target_g - g).abs < 30 and (target_b - b).abs < 30
      if (target_r - r).abs < 100 and (target_g - g).abs < 100 and (target_b - b).abs < 100
        preferred.push(image)
      end
    end

    render text: preferred
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_target_image
      @target_image = TargetImage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def target_image_params
      params.require(:target_image).permit(:title)
    end
end
