class TargetWordsController < ApplicationController
  before_action :set_target_word, only: [:show, :edit, :update, :destroy]

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
    @target_word = TargetWord.new(target_word_params)

    respond_to do |format|
      if @target_word.save
        format.html { redirect_to @target_word, notice: 'Target word was successfully created.' }
        format.json { render action: 'show', status: :created, location: @target_word }
      else
        format.html { render action: 'new' }
        format.json { render json: @target_word.errors, status: :unprocessable_entity }
      end
    end
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
      format.html { redirect_to target_words_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_target_word
      @target_word = TargetWord.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def target_word_params
      params.require(:target_word).permit(:word)
    end
end
