require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe TargetWordsController do

  # This should return the minimal set of attributes required to create a valid
  # TargetWord. As you add validations to TargetWord, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "word" => "MyString" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # TargetWordsController. Be sure to keep this updated too.
  let(:valid_session) { {} }
  let(:user) { FactoryGirl.create(:user) }
  before do
    sign_in user
  end

  describe "GET index" do
    it "assigns all target_words as @target_words" do
      target_word = TargetWord.create! valid_attributes
      get :index, {}, valid_session
      assigns(:target_words).should eq([target_word])
    end
  end

  describe "GET show" do
    it "assigns the requested target_word as @target_word" do
      target_word = TargetWord.create! valid_attributes
      get :show, {:id => target_word.to_param}, valid_session
      assigns(:target_word).should eq(target_word)
    end
  end

  describe "GET new" do
    it "assigns a new target_word as @target_word" do
      get :new, {}, valid_session
      assigns(:target_word).should be_a_new(TargetWord)
    end
  end

  describe "GET edit" do
    it "assigns the requested target_word as @target_word" do
      target_word = TargetWord.create! valid_attributes
      get :edit, {:id => target_word.to_param}, valid_session
      assigns(:target_word).should eq(target_word)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new TargetWord" do
        person = FactoryGirl.create(:person)
        expect {
          post :create, { target_word: valid_attributes, id: person.id }, valid_session
        }.to change(TargetWord, :count).by(1)
      end

      it "assigns a newly created target_word as @target_word" do
        person = FactoryGirl.create(:person)
        post :create, { target_word: valid_attributes, id: person.id }, valid_session
        assigns(:target_word).should be_a(TargetWord)
        assigns(:target_word).should be_persisted
      end

      # ユーザの登録ワード一覧ページへリダイレクトする事
      it "redirects to the list of target_words" do
        person = FactoryGirl.create(:person)
        post :create, { target_word: valid_attributes, id: person.id }, valid_session
        response.should redirect_to(show_target_words_users_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved target_word as @target_word" do
        # Trigger the behavior that occurs when invalid params are submitted
        person = FactoryGirl.create(:person)
        TargetWord.any_instance.stub(:save).and_return(false)
        post :create, { target_word: valid_attributes, id: person.id }, valid_session
        assigns(:target_word).should be_a_new(TargetWord)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        person = FactoryGirl.create(:person)
        TargetWord.any_instance.stub(:save).and_return(false)
        post :create, { target_word: valid_attributes, id: person.id }, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested target_word" do
        target_word = TargetWord.create! valid_attributes
        # Assuming there are no other target_words in the database, this
        # specifies that the TargetWord created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        TargetWord.any_instance.should_receive(:update).with({ "word" => "MyString" })
        put :update, {:id => target_word.to_param, :target_word => { "word" => "MyString" }}, valid_session
      end

      it "assigns the requested target_word as @target_word" do
        target_word = TargetWord.create! valid_attributes
        put :update, {:id => target_word.to_param, :target_word => valid_attributes}, valid_session
        assigns(:target_word).should eq(target_word)
      end

      it "redirects to the target_word" do
        target_word = TargetWord.create! valid_attributes
        put :update, {:id => target_word.to_param, :target_word => valid_attributes}, valid_session
        response.should redirect_to(target_word)
      end
    end

    describe "with invalid params" do
      it "assigns the target_word as @target_word" do
        target_word = TargetWord.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        TargetWord.any_instance.stub(:save).and_return(false)
        put :update, {:id => target_word.to_param, :target_word => { "word" => "invalid value" }}, valid_session
        assigns(:target_word).should eq(target_word)
      end

      it "re-renders the 'edit' template" do
        target_word = TargetWord.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        TargetWord.any_instance.stub(:save).and_return(false)
        put :update, {:id => target_word.to_param, :target_word => { "word" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested target_word" do
      target_word = TargetWord.create! valid_attributes
      expect {
        delete :destroy, {:id => target_word.to_param}, valid_session
      }.to change(TargetWord, :count).by(-1)
    end

    it "redirects to the target_words list" do
      target_word = TargetWord.create! valid_attributes
      delete :destroy, {:id => target_word.to_param}, valid_session
      response.should redirect_to(target_words_url)
    end
  end

  describe "search action" do
    it "assigns ransack variable" do
      get :search, {q:{"name_display_cont"=>"まどか"}}, valid_session
      expect(assigns(:search)).to be_a(Ransack::Search)
    end
    it "assigns search result properly" do
      FactoryGirl.create(:person_madoka)
      get :search, {q:{"name_display_cont"=>"まどか"}}, valid_session
      expect(assigns(:people).count).to eq(1)
    end
  end

end