require 'resque_web'

Ispick::Application.routes.draw do
  # RequeWeb
  mount ResqueWeb::Engine => '/resque_web'
  ResqueWeb::Engine.eager_load!

  # Root path
  root 'welcome#index'

  # Devise
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }, path: '', path_names: {
    sign_in: 'signin_with_password'
  }
  devise_scope :user do
    get 'reset_password' => 'devise/passwords#new'
  end

  # Resources
  resources :users do
    collection do
      get 'home'
      get 'home_debug'
      get 'settings'
      get 'preferences'
      post 'preferences'
      get 'boards'
      get 'share_tumblr'
      get 'new_avatar'
      post 'create_avatar'
      get 'search'
      get 'show_illusts'
      get 'show_target_images'
      delete 'delete_target_word'

      get "/home/:year/:month/:day" => "users#home",
        constraints: { year: /[1-9][0-9]{3}/, month: /[01][0-9]/, day: /[0123][0-9]/ }

      # routes for debug
      get 'download_favored_images'
      get 'debug_illust_detection'
      get 'debug_crawling'
      get 'toggle_miniprofiler'
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
      get 'prefer'
      get 'show_delivered'
    end
  end

  resources :image_boards do
    collection do
      get 'boards'
      get 'reload'
      get 'boards_another'
      post 'create_another'
    end
  end

  resources :favored_images, only: [:show, :destroy]
  resources :images, only: [:index, :show, :destroy]
  resources :images do
    member do
      put 'favor'
      put 'favor_another'
      put 'hide'
      get 'show_debug'
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
