class Users::SessionsController < Devise::SessionsController

  # GET /resource/sign_in
  def new
    #resource = build_resource
    #clean_up_passwords(resource)
    #respond_with_navigational(resource, stub_options(resource)){ render_with_scope :new }

    @images = Image.search_images('aqua eyes').page(params[:page]).per(25)
    @images = Image.search_images('pixiv').page(params[:page]).per(25) if @images.empty?
    @images = Image.get_recent_images(500).page(params[:page]).per(25) if @images.empty?
    @first = true
    @first = false if params[:page] and params[:page].to_i > 1

    super
  end

  def build_resource(hash=nil)
    self.resource = resource_class.new_with_session(hash || {}, session)
  end

end