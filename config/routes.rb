Rails.application.routes.draw do

  root 'pages#home'

  get 'api/users' => 'api/users#index'
  post 'api/users' => 'api/users#create'
  get 'api/user/:id/android_apps' => 'api/users#android_apps_index'
  post 'api/user/:id/android_apps' => 'api/users#android_apps_create'

  get 'api/android_apps' => 'api/android_apps#index'

  # post 'api/users/upsert' => 'api#users_upsert', as: :users_upsert
  # post 'api/user/apps/upsert' => 'api#user_apps_upsert', as: :user_apps_upsert

  # post 'api/recommendations/create' => 'api#recommendations_create', as: :recommendations_create


  # get 'api/recommendations/list' => 'api#recommendations_list', as: :recommendations_list


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
