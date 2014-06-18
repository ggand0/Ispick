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

describe DeliveredImagesController do

  # This should return the minimal set of attributes required to create a valid
  # DeliveredImage. As you add validations to DeliveredImage, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "avoided" => false } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # DeliveredImagesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all delivered_images as @delivered_images" do
      delivered_image = DeliveredImage.create! valid_attributes
      get :index, {}, valid_session
      assigns(:delivered_images).should eq([delivered_image])
    end
  end

  describe "GET show" do
    it "assigns the requested delivered_image as @delivered_image" do
      delivered_image = DeliveredImage.create! valid_attributes
      get :show, {:id => delivered_image.to_param}, valid_session
      assigns(:delivered_image).should eq(delivered_image)
    end
  end

  describe "GET new" do
    it "assigns a new delivered_image as @delivered_image" do
      get :new, {}, valid_session
      assigns(:delivered_image).should be_a_new(DeliveredImage)
    end
  end

  describe "GET edit" do
    it "assigns the requested delivered_image as @delivered_image" do
      delivered_image = DeliveredImage.create! valid_attributes
      get :edit, {:id => delivered_image.to_param}, valid_session
      assigns(:delivered_image).should eq(delivered_image)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new DeliveredImage" do
        expect {
          post :create, {:delivered_image => valid_attributes}, valid_session
        }.to change(DeliveredImage, :count).by(1)
      end

      it "assigns a newly created delivered_image as @delivered_image" do
        post :create, {:delivered_image => valid_attributes}, valid_session
        assigns(:delivered_image).should be_a(DeliveredImage)
        assigns(:delivered_image).should be_persisted
      end

      it "redirects to the created delivered_image" do
        post :create, {:delivered_image => valid_attributes}, valid_session
        response.should redirect_to(DeliveredImage.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved delivered_image as @delivered_image" do
        # Trigger the behavior that occurs when invalid params are submitted
        DeliveredImage.any_instance.stub(:save).and_return(false)
        post :create, {:delivered_image => { "avoided" => "invalid value" }}, valid_session
        assigns(:delivered_image).should be_a_new(DeliveredImage)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        DeliveredImage.any_instance.stub(:save).and_return(false)
        post :create, {:delivered_image => { "avoided" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested delivered_image" do
        delivered_image = DeliveredImage.create! valid_attributes
        # Assuming there are no other delivered_images in the database, this
        # specifies that the DeliveredImage created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        DeliveredImage.any_instance.should_receive(:update).with({ "avoided" => true })
        put :update, {:id => delivered_image.to_param, :delivered_image => { "avoided" => true }}, valid_session
      end

      it "assigns the requested delivered_image as @delivered_image" do
        delivered_image = DeliveredImage.create! valid_attributes
        put :update, {:id => delivered_image.to_param, :delivered_image => valid_attributes}, valid_session
        assigns(:delivered_image).should eq(delivered_image)
      end

      it "redirects to the delivered_image" do
        delivered_image = DeliveredImage.create! valid_attributes
        put :update, {:id => delivered_image.to_param, :delivered_image => valid_attributes}, valid_session
        response.should redirect_to(delivered_image)
      end
    end

    describe "with invalid params" do
      it "assigns the delivered_image as @delivered_image" do
        delivered_image = DeliveredImage.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        DeliveredImage.any_instance.stub(:save).and_return(false)
        put :update, {:id => delivered_image.to_param, :delivered_image => { "avoided" => "invalid value" }}, valid_session
        assigns(:delivered_image).should eq(delivered_image)
      end

      it "re-renders the 'edit' template" do
        delivered_image = DeliveredImage.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        DeliveredImage.any_instance.stub(:save).and_return(false)
        put :update, {:id => delivered_image.to_param, :delivered_image => { "avoided" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested delivered_image" do
      delivered_image = DeliveredImage.create! valid_attributes
      expect {
        delete :destroy, {:id => delivered_image.to_param}, valid_session
      }.to change(DeliveredImage, :count).by(-1)
    end

    it "redirects to the delivered_images list" do
      delivered_image = DeliveredImage.create! valid_attributes
      delete :destroy, {:id => delivered_image.to_param}, valid_session
      response.should redirect_to(delivered_images_url)
    end
  end

  describe "PUT favor" do
    before do
      login_user
    end
    it "Add delivered_image to User.favored_images" do
      delivered_image = FactoryGirl.create(:delivered_image)
      current_user = User.first

      put :favor, {
        id: delivered_image.id,
        board: 'Default',
        delivered_image: delivered_image.as_json,
        render: 'true'
      }, valid_session

      # ImageBoardに１枚追加されているはずである
      expect(current_user.image_boards.first.favored_images.count).to eq(1)
      expect(response).to redirect_to show_favored_images_users_path
    end

    it "redirects to show_favored_images_users_path" do
      favored_image = FactoryGirl.create(:favored_image_with_delivered)
      put :favor, {
        id: favored_image.delivered_image.id,
        board: 'Default',
        delivered_image: favored_image.delivered_image,
        render: 'true'
      }, valid_session

      expect(response).to redirect_to show_favored_images_users_path
    end
  end

end
