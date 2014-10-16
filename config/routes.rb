require 'resque_web'

Ispick::Application.routes.draw do

  # Root path
  #root 'welcome#index'
  #root 'welcome#signup', :as => 'signup_welcome'
  match '/' => 'welcome#index', :via => :get
  match '/signup' => 'welcome#signup', :as => 'signup_welcome', :via => :get
  match 'contact' => 'contact#new', :as => 'new_contact', :via => :get
  match 'contact' => 'contact#create', :as => 'create_contact', :via => :post

  # Debugging paths
  scope "/debug" do
    get "/index" => "debug#index", as: "index_debug"
    get '/home' => 'debug#home', as: "home_debug"
    get '/download' => 'debug#download_favored_images', as: "download_debug"
    get '/illust_detection' => 'debug#debug_illust_detection', as: "illust_detection_debug"
    get '/crawling' => 'debug#debug_crawling', as: "crawling_debug"
    get '/miniprofiler' => 'debug#toggle_miniprofiler', as: "miniprofiler_debug"

    get '/boards_another' => 'debug#boards_another', as: "boards_another_debug"
    post '/create_another' => 'debug#create_another', as: "create_another_debug"
    put '/favor_another' => 'debug#favor_another', as: "favor_another_debug"
    get '/show_debug' => 'debug#show_debug', as: "show_image_debug"
  end

  # RequeWeb configuration
  mount ResqueWeb::Engine => '/resque_web'
  ResqueWeb::Engine.eager_load!


  # Devise
  devise_for :admins, ActiveAdmin::Devise.config
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    sessions: "users/sessions"
  }, path: '', path_names: {
    sign_in: 'signin_with_password'
  }
  devise_scope :user do
    get 'reset_password' => 'devise/passwords#new'
  end
  ActiveAdmin.routes(self)

  # Resources
  resources :authorizations, only: [:destroy]

  resources :users do
    collection do
      get 'home'
      get 'settings'
      get 'new_avatar'
      post 'create_avatar'
      get 'preferences'
      post 'preferences'
      get 'boards'
      get 'search'
      delete 'delete_target_word'
      delete 'delete_tag'

      get "/home/:year/:month/:day" => "users#home",
        constraints: { year: /[1-9][0-9]{3}/, month: /[01][0-9]/, day: /[0123][0-9]/ }

      # debug or temporary created paths
      #get 'share_tumblr'  # for debug
      get 'show_target_images'
    end
  end

  resources :favored_images, only: [:show, :destroy]
  resources :image_boards do
    collection do
      get 'boards'
    end
  end
  resources :images, only: [:index, :show, :destroy]
  resources :images do
    member do
      put 'favor'
      put 'hide'
    end
  end


  resources :target_images do
    member do
      get 'prefer'
      get 'show_delivered'
      get 'switch'
    end
  end

  resources :target_words do
    collection do
      match 'search' => 'target_words#search', via: [:get, :post], as: :search
      post 'attach'
    end
    member do
      get 'images'
    end
  end
  resources :tags do
    collection do
      match 'search' => 'tags#search', via: [:get, :post], as: :search
      post 'attach'
    end
    member do
      get 'images'
    end
  end
  resources :people do
    collection do
      match 'search' => 'people#search', via: [:get, :post], as: :search
    end
  end


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
