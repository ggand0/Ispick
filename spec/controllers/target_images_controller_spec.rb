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

describe TargetImagesController do

  # This should return the minimal set of attributes required to create a valid
  # TargetImage. As you add validations to TargetImage, be sure to
  # adjust the attributes here as well.
  #let(:valid_attributes) { { "title" => "MyString" } }
  let(:valid_attributes) {{
    title: "MyString",
    data: fixture_file_upload('files/madoka.png')
  }}

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # TargetImagesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all target_images as @target_images" do
      target_image = TargetImage.create! valid_attributes
      get :index, {}, valid_session
      assigns(:target_images).should eq([target_image])
    end
  end

  describe "GET show" do
    it "assigns the requested target_image as @target_image" do
      target_image = TargetImage.create! valid_attributes
      get :show, {:id => target_image.to_param}, valid_session
      assigns(:target_image).should eq(target_image)
    end
  end

  describe "GET new" do
    it "assigns a new target_image as @target_image" do
      get :new, {}, valid_session
      assigns(:target_image).should be_a_new(TargetImage)
    end
  end

  describe "GET edit" do
    it "assigns the requested target_image as @target_image" do
      target_image = TargetImage.create! valid_attributes
      get :edit, {:id => target_image.to_param}, valid_session
      assigns(:target_image).should eq(target_image)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new TargetImage" do
        expect {
          post :create, {:target_image => valid_attributes}, valid_session
        }.to change(TargetImage, :count).by(1)
      end

      it "assigns a newly created target_image as @target_image" do
        post :create, {:target_image => valid_attributes}, valid_session
        #puts :target_image# => target_image
        assigns(:target_image).should be_a(TargetImage)
        assigns(:target_image).should be_persisted
      end

      it "redirects to the created target_image" do
        post :create, {:target_image => valid_attributes}, valid_session
        response.should redirect_to(TargetImage.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved target_image as @target_image" do
        # Trigger the behavior that occurs when invalid params are submitted
        TargetImage.any_instance.stub(:save).and_return(false)
        post :create, { target_image: { title: "invalid value", data: nil }}, valid_session
        assigns(:target_image).should be_a_new(TargetImage)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        TargetImage.any_instance.stub(:save).and_return(false)
        post :create, { target_image: { title: "invalid value", data: nil }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    before :each do
      @updated_attr = {
        title: "updated",
        data: fixture_file_upload('files/madoka.png')
      }
      @updated = {
        title: "invalid updated",
        data: fixture_file_upload('files/madoka.png')
      }
    end

    describe "with valid params" do
      it "updates the requested target_image" do
        #TargetImage.delete_all
        #puts '¥n'
        #puts 'DEBUG UPDATE TEST : ' + TargetImage.count.to_s

        # Assuming there are no other target_images in the database, this
        # specifies that the TargetImage created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        #TargetImage.any_instance.should_receive(:update).with({ "title" => "MyString" })
        target_image = TargetImage.create! valid_attributes

        # TargetImage.any_instanceだと何故か通らないのでexpect_any_instance_ofを使う
        expect_any_instance_of(TargetImage).to receive(:update_attributes).with(@updated_attr)

        #put :update, { id: target_image.to_param, target_image: @updated}, valid_session
        put :update, { id: target_image.id, target_image: @updated_attr }, valid_session
      end

      it "assigns the requested target_image as @target_image" do
        target_image = TargetImage.create! valid_attributes
        put :update, {:id => target_image.to_param, :target_image => valid_attributes}, valid_session
        assigns(:target_image).should eq(target_image)
      end

      it "redirects to the target_image" do
        target_image = TargetImage.create! valid_attributes
        put :update, {:id => target_image.to_param, :target_image => valid_attributes}, valid_session
        response.should redirect_to(target_image)
      end
    end

    describe "with invalid params" do
      it "assigns the target_image as @target_image" do
        target_image = TargetImage.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        TargetImage.any_instance.stub(:save).and_return(false)
        put :update, {:id => target_image.to_param, :target_image => { "title" => "invalid value", data: nil }}, valid_session
        assigns(:target_image).should eq(target_image)
      end

      it "re-renders the 'edit' template" do
        target_image = TargetImage.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        TargetImage.any_instance.stub(:save).and_return(false)
        put :update, {:id => target_image.to_param, :target_image => { "title" => "invalid value", data: nil }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested target_image" do
      target_image = TargetImage.create! valid_attributes
      expect {
        delete :destroy, {:id => target_image.to_param}, valid_session
      }.to change(TargetImage, :count).by(-1)
    end

    it "redirects to the target_images list" do
      target_image = TargetImage.create! valid_attributes
      delete :destroy, {:id => target_image.to_param}, valid_session
      response.should redirect_to(target_images_url)
    end
  end




  describe "Find preferred images" do
    it "returns list of images" do
      Image.new
      target_image = TargetImage.create! valid_attributes
      #images = target_image.prefer
      #images.should be_an Array

      get :prefer, {:id => target_image.id}, valid_session
      response.should render_template("prefer")
    end
  end
end
