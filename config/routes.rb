require 'resque_web'

Ispic::Application.routes.draw do
  resources :target_words

  get "welcome/index"

  # Devise
  devise_for :users, controllers: {
    #:sessions      => "users/sessions",
    #:registrations => "users/registrations",
    passwords:          "users/passwords",
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  resources :users do
    collection do
      get 'home'
      get 'show_target_images'
      get 'show_target_words'
      get 'show_favored_images'
      get 'download_favored_images'
    end
  end

  resources :delivered_images do
    collection do
      get 'show_user_image'
    end
    member do
      put 'favor'
    end
  end

  resources :target_images do
    member do
      get 'prefer'
    end
  end

  resources :images, only: [:index, :show, :destroy]

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'
  mount ResqueWeb::Engine => '/resque_web'
  ResqueWeb::Engine.eager_load!

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
