class TargetWordsController < ApplicationController
  before_action :set_target_word, only: [:show, :edit, :update, :destroy, :show_delivered, :switch]

  # GET /target_words
  # GET /target_words.json
  def index
    @target_words = TargetWord.all
  end

  # GET /target_words/1
  # GET /target_words/1.json
  def show
  end

  # GET /target_words/new
  def new
    @target_word = TargetWord.new
  end

  # GET /target_words/1/edit
  def edit
  end

  # POST /target_words
  # POST /target_words.json
  def create
    @target_word = get_target_word(target_word_params)

    unless current_user.target_words.where(word: @target_word.word).empty?
      @target_word.errors.add(:base, "That target_word is already registered!!")
      return render action: 'new'
    end

    #current_user.target_words << @target_word
    respond_to do |format|
      if @target_word.id
        current_user.target_words << @target_word
        format.html { redirect_to controller: 'users', action: 'show_target_words' }
    elsif @target_word.id.nil? and current_user.save
        format.html { redirect_to controller: 'users', action: 'show_target_words' }
        format.json { render action: 'show', status: :created, location: @target_word }
      else
        format.html { render action: 'new' }
        format.json { render json: @target_word.errors, status: :unprocessable_entity }
      end
    end
  end

  def get_target_word(target_word_params)
    word = target_word_params['word']
    target_word = TargetWord.where(word: word)
    #target_word = target_word.empty? ? TargetWord.new(word: word) : target_word.first
    target_word = target_word.empty? ? current_user.target_words.build(target_word_params) : target_word.first

    target_word.person = Person.find(params[:id]) if params[:id]
    target_word
  end

  # PATCH/PUT /target_words/1
  # PATCH/PUT /target_words/1.json
  def update
    respond_to do |format|
      if @target_word.update(target_word_params)
        format.html { redirect_to @target_word, notice: 'Target word was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @target_word.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /target_words/1
  # DELETE /target_words/1.json
  def destroy
    @target_word.destroy
    respond_to do |format|
      format.html { redirect_to show_target_words_users_path }
      format.json { head :no_content }
    end
  end

  def search
    @target_word = TargetWord.new
    @search = Person.search(params[:q])
    @people = @search.result(distinct: true).page(params[:page]).per(50)
  end

  # 特定のタグに配信されている画像のみを表示する
  # UsersControllerに移動予定
  def show_delivered
    if signed_in?
      delivered_images = @target_word.delivered_images.where.not(images: { site_name: 'twitter' }).
        where('avoided IS NULL or avoided = false').
        joins(:image).
        reorder('created_at DESC')

      # 配信日で絞り込む場合
      if params[:date]
        date = params[:date]
        date = DateTime.parse(date).to_date
        delivered_images = delivered_images.where(created_at: date.to_datetime.utc..(date+1).to_datetime.utc)
      end

      @delivered_images = delivered_images.page(params[:page]).per(25)
      @delivered_images_all = delivered_images
      render action: '../users/signed_in'
    else
      render action: 'not_signed_in'
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_target_word
      @target_word = TargetWord.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def target_word_params
      params.require(:target_word).permit(:word, :id)
    end
end
