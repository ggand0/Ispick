require "#{Rails.root}/app/services/target_images_service"
require "#{Rails.root}/app/workers/target_images_face"

class TargetImagesController < ApplicationController
  before_action :set_target_image, only: [:show, :edit, :update, :destroy]

  # GET /target_images
  # GET /target_images.json
  def index
    @target_images = TargetImage.all.page(params[:page])
  end

  # GET /target_images/1
  # GET /target_images/1.json
  def show
    @target_image = TargetImage.find(params[:id])
    # 顔の特徴量を、JSON文字列からJSON Arrayへ変換する
    if @target_image.feature.nil?
      @face_feature = 'Not extracted.'
    else
      #@face_feature = JSON.parse(@target_image.feature.face)
      @face_feature = @target_image.feature.face
    end
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
    @target_image = TargetImage.new(target_image_params)

    respond_to do |format|
      if @target_image.save
        # 顔特徴抽出処理をbackground jobに投げる
        Resque.enqueue(Face, @target_image.id)

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

    respond_to do |format|
      #if @target_image.update(target_image_params)
      if @target_image.update_attributes(hash)
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




  # 顔の特徴量をもとに、髪・目の色が似てる画像一覧を表示する
  # GET /target_images/1/prefer
  def prefer
    @preferred = []
    target_image = TargetImage.find(params[:id])

    # 正しい特徴値が無い場合はindexにredirectする。この後の処理は行いたくないのでreturnもする。
    # http://stackoverflow.com/questions/888963/testing-for-undefined-variables-in-ruby-a-la-javascript
    if defined?(target_image.feature)
      return redirect_to target_images_path, notice: 'Not extracted yet. まだ抽出されていません。'
    elsif target_image.feature.face == '[]'
      return redirect_to target_images_path, notice: 'Could not get face feature from this image. 抽出できませんでした。'
    end

    face_feature = JSON.parse(target_image.feature.face)
    target_r = face_feature[0]['hair_color']['red'].to_i
    target_g = face_feature[0]['hair_color']['green'].to_i
    target_b = face_feature[0]['hair_color']['blue'].to_i
    @target_rgb = ["%.2f" % target_r, "%.2f" % target_g, "%.2f" % target_b]
    @target_hsv = Utility::rgb_to_hsv(target_r, target_g, target_b, false)

    Image.all.each do |image|
      # 抽出されていないか、抽出出来ていないImageは飛ばす
      if (not image.feature.nil? and image.feature.face == '[]' or
        image.feature.nil?)
        next
      end

      image_face = JSON.parse(image.feature.face)
      r = image_face[0]['hair_color']['red'].to_i
      g = image_face[0]['hair_color']['green'].to_i
      b = image_face[0]['hair_color']['blue'].to_i
      hsv = Utility::rgb_to_hsv(r, g, b, false)

      if (@target_hsv[0] - hsv[0]).abs < 20
        hsv = Utility::round_array(hsv)
        @preferred.push({image: image, hsv: hsv})
      end
    end

    # Pagenate the array
    @preferred = Kaminari.paginate_array(@preferred).page(params[:page]).per(100)
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
