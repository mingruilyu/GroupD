Rails.application.routes.draw do
  mount_devise_token_auth_for 'Account', at: 'auth', controllers: {
    omniauth_callbacks: 'account/auth_callbacks',
  }

  get 'auth/confirmation/success' => 'account/auth_callbacks#confirmation_success'
  get 'auth/password/reset' => 'account/auth_callbacks#reset_password'
  post 'chat' => 'chats#chat', constraints: { format: :xml }
  get 'chat' => 'chats#configuration'

  namespace :account, format: true, constraints: { format: :json } do
    post ':account_id/cellphone' => 'cellphones#create' 
    post ':account_id/cellphone/:id' => 'cellphones#resend'
    put ':account_id/cellphone/:id' => 'cellphones#update' 
  end

  resources :merchants, only: [:show, :update], module: :merchants, 
    format: true, constraints: { format: :json } do
    resources :dropoffs, format: true, only: [:index, :create]

    resources :restaurants, only: [:index, :create] do
      resources :caterings, only: :create

      resources :dishes, only: :create

      resources :combos, only: :create
      get 'combos/recent' => 'combos#recent'
    end

    resources :shippings, only: [:create, :update, :destroy] do
      member do
        get 'list_orders' => 'shippings#list_orders'
        put 'update_state' => 'shippings#update_state'
      end
    end

    resources :dishes, only: [:destroy, :update]

    resources :combos, only: [:destroy, :update, :show]

    resources :uploads, only: :create

    resources :debts, only: :index

    resources :transactions, only: [:index, :update, :destroy]
    get 'transactions/pending' => 'transactions#pending'

    put 'orders/:id/approve' => 'orders#approve'
    put 'orders/:id/pickup' => 'orders#pickup'
  end

  namespace :merchant, format: true, constraints: { format: :json } do
    resources :dropoffs, only: :destroy
    resources :restaurants, only: [:update, :destroy, :new]
  end
  
  resources :customers, module: :customers, format: true, 
    constraints: { format: :json } do
    resources :orders, only: [:index, :show]
    put 'orders/recent' => 'orders#recent'
    put 'orders/:id/cancel' => 'orders#cancel' 

    resources :payments, only: [:create, :destroy, :show, :index]
    resources :qr_codes, only: :new
  end

  resources :restaurants, module: :restaurant, only: :show, 
    format: true, constraints: { format: :json }do

    resources :dishes, only: :index

    resources :combos, only: :index

    resources :caterings, only: :index
    get 'caterings/recent' => 'caterings#recent'
  end

  namespace :restaurant, format: true, 
    constraints: { format: :json } do
    resources :caterings, only: :show

    resources :combos, only: :show

    resources :dishes, only: :show

    get 'new' => 'restaurants#new'
  end

  resources :locations, format: true, 
    constraints: { format: :json } do
    collection do
      get 'query'
    end
  end
  
  get 'buildings/coord' => 'buildings#query_by_coord', format: true, 
    constraints: { format: :json }
  get 'buildings/city_company' => 'buildings#query_by_city_company', 
    format: true, constraints: { format: :json }
  get 'buildings/address_name' => 'buildings#fuzzy_query_by_address_name', 
    format: true, constraints: { format: :json }

  resources :companies, only: :index, format: true, 
    constraints: { format: :json }
  get 'companies/:name' => 'companies#query', format: true, 
    constraints: { format: :json }
  
  resources :uploads, only: :create, format: true, 
    constraints: { format: :json }

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
