Rails.application.routes.draw do

  devise_for :accounts, controllers: { 
    registrations:  'devise/registrations',
    sessions:       'devise/sessions'
  }

  resources :merchants, only: [:show, :update], module: :merchant do
    resources :dropoffs, only: [:index, :create]

    resources :restaurants, only: [:index, :create]
  end

  namespace :merchant do
    resources :dropoffs, only: :destroy
  end
  
  resources :customers, module: :customer do
    resources :orders, only: :index
    put 'orders/recent' => 'orders#recent'

    resources :payments, only: [:create, :destroy, :show, :index]
  end

  namespace :customer do
    resources :orders, only: [:show, :update, :destroy] do
      resources :order_items, only: [:index, :create, :new]
    end
    put 'orders/:id/cancel' => 'orders#cancel' 
    resources :order_items, only: [:destroy]

    get 'caterings/recent' => 'caterings#recent'
    resources :buildings, only: [:show]
  end
      
  resources :restaurants, module: :restaurant, only: [:show, :update,
    :destroy] do
    get 'shippings/recent' => 'shippings#recent'

    resources :dishes, only: [:index, :create]

    resources :combos, only: [:index, :create]

    resources :caterings, only: [:index, :create]
    get 'caterings/recent' => 'caterings#recent'
  end

  namespace :restaurant do
    resources :caterings, only: [:show, :update, :destroy]

    resources :shippings, only: [:show, :update]
    get 'shippings/:id/location' => 'shippings#location'
    put 'shippings/:id/location' => 'shippings#location'

    resources :combos, only: [:destroy, :update, :show]

    resources :dishes, only: [:destroy, :update, :show]
  end
 
  resources :locations
  
  resources :buildings

  resources :cellphones

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

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
