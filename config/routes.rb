Rails.application.routes.draw do
  mount_devise_token_auth_for 'Account', at: 'auth', controllers: {
    registrations: 'account/registrations'
  }

  resources :merchants, only: [:show, :update], module: :merchant do
    resources :dropoffs, only: [:index, :create]

    resources :restaurants, only: [:index, :create] do
      resources :caterings, only: :create

      resources :dishes, only: :create

      resources :combos, only: :create
      get 'combos/recent' => 'combos#recent'
    end

    resources :caterings, only: [:update, :destroy]

    resources :dishes, only: [:destroy, :update]

    resources :combos, only: [:destroy, :update, :show]

    resources :uploads, only: :create
  end

  namespace :merchant do
    resources :dropoffs, only: :destroy
    resources :restaurants, only: [:update, :destroy, :new]
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

  end
      
  resources :restaurants, module: :restaurant, only: :show do
    get 'shippings/recent' => 'shippings#recent'

    resources :dishes, only: :index

    resources :combos, only: :index

    resources :caterings, only: :index
    get 'caterings/recent' => 'caterings#recent'
  end

  namespace :restaurant do
    resources :caterings, only: :show

    resources :combos, only: :show

    resources :dishes, only: :show

    resources :shippings, only: [:show, :update]
    get 'shippings/:id/location' => 'shippings#location'
    put 'shippings/:id/location' => 'shippings#location'

    get 'new' => 'restaurants#new'
  end
 
  resources :locations do
    collection do
      get 'query'
    end
  end
  
  get 'buildings/coord' => 'buildings#query_by_coord'
  get 'buildings/city_company' => 'buildings#query_by_city_company'
  get 'buildings/address_name' => 'buildings#fuzzy_query_by_address_name'

  resources :companies, only: :index
  get 'companies/:name' => 'companies#query'
  
  resources :cellphones

  resources :uploads, only: :create

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
