class TargetWordsController < ApplicationController
  before_action :set_target_word, only: [:show, :edit, :update, :destroy, :images, :attach]

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

=begin
  # POST
  # This action only get the existing TargetWord record,
  # and add it to current_user.target_words.
  def attach
    # Get the existing target_word record
    current_user.target_words << @target_word

    respond_to do |format|
      format.html { redirect_to controller: 'users', action: 'preferences' }
      format.js { @target_words = current_user.target_words; render partial: 'layouts/reload_followed_tags' }
    end
  end

  # POST /target_words
  # POST /target_words.json
  # TODO: Refactor this if possible
  def create
    # Get the existing target_word object or create a new one.
    # 既に登録されている同名のTargetWordレコードがある場合はそれを取ってくる、無ければ新しくオブジェクトを生成する
    @target_word = get_target_word(target_word_params)

    # If the user has already registerd the target_word, flash it as an error at the 'new' template.
    # もしユーザが既に同名のタグを登録していた場合はそれを通知する
    unless current_user.target_words.where(name: @target_word.name).empty?
      @target_word.errors.add(:base, "That target_word is already registered!!")
      return render action: 'new'
    end

    respond_to do |format|
      # If the id exists, which means @target_word comes from existing record, redirect after associated it to the user.
      # IDが存在する=既存のTargetWordを取ってきている場合は、関連づけてからリダイレクト
      if @target_word.id
        current_user.target_words << @target_word
        format.html { redirect_to controller: 'users', action: 'preferences' }
        format.js { @target_words = current_user.target_words; render partial: 'layouts/reload_followed_tags' }

      # If the id equals to nil, which means @target_word is newly initialized, redirect after saving it.
      # IDがnilである=新しくTargetWordをbuildしている場合は、保存してからリダイレクト
      elsif @target_word.id.nil? and current_user.save
        # Call the SearchImage callback method if you need it for debugging purpose
        # デバッグ用のparamsがある場合はSearchImageのjobをenqueueする
        current_user.search_keyword(@target_word) if params[:debug]

        format.html { redirect_to controller: 'users', action: 'preferences' }
        format.js { @target_words = current_user.target_words; render partial: 'layouts/reload_followed_tags' }
        format.json { render partial: 'create' }

      # Otherwise, probablly it has some problems, rerender the 'new' template
      # それ以外の場合は何らかの問題が起きている可能性が高いのでフォームを再描画
      else
        format.html { render action: 'new' }
        format.js { render nothing: true }
        format.json { render json: @target_word.errors, status: :unprocessable_entity }
      end
    end
  end

  # Returns a TargetWord object based on the hash.
  # If a TargetWord record which has exact same name exists, returns that record.
  # paramsのwordと同名の既存レコードがある場合それを返し、無ければ新しくTargetWordオブジェクトを生成して返す。
  # @param target_word_params [Hash]
  # @return [TargetWord]
  def get_target_word(target_word_params)
    name = target_word_params['name']
    target_word = TargetWord.where(name: name)
    target_word = target_word.empty? ? current_user.target_words.build(target_word_params) : target_word.first

    target_word.person = Person.find(params[:id]) if params[:id]
    target_word
  end

  # Used in attach action
  def search_target_word(target_word_params)
    # Since all TargetWord records should have (non-nil) name_english value,
    # use it to get the corresponding record.
    name_en = target_word_params['name_english']
    target_word = TargetWord.where(name_english: name_english)
    target_word
  end
=end
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
      format.html { redirect_to preferences_users_path }
      format.json { head :no_content }
    end
  end

  # An action used with ransack lib.
  def search
    @target_word = TargetWord.new
    @search = Person.search(params[:q])
    @people = @search.result(distinct: true).page(params[:page]).per(50)
  end

  # Show images associated by a specific tag. Will be moved to the UsersController class.
  # 特定のタグに配信されている画像のみを表示する。UsersControllerに移動予定
  def images
    redirect_to '/signin_with_password' unless signed_in?

    # Get images of the TargetWord record
    images = @target_word.get_images

    # Filter by created_at attribute
    # 配信日で絞り込む場合
    if params[:date]
      date = params[:date]
      date = DateTime.parse(date).to_date
      images = Image.filter_by_date(images, date)
    end

    @images = images.page(params[:page]).per(25)
    @count = images.select('images.id').count
    render action: '../users/home'
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_target_word
      @target_word = TargetWord.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def target_word_params
      params.require(:target_word).permit(:name, :id)
    end
end
