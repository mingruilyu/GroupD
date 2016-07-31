Rails.application.routes.draw do

  root      'welcome#index'

  devise_for :accounts, controllers: { 
    registrations:  'registrations',
    sessions:       'sessions'
  }

  resources :merchants do
    resources :dropoffs
  end

  resources :customers do
    resources :orders
    resources :payments
    resource  :address, only: [:edit, :update]
  end

  resources :cellphones

  scope 'dropoffs/:dropoff_id' do
    resources :shippings, only: [:index]
  end
  resources :shippings, only: [:show, :create, :new]

  resources :carts do
    resources :dish_cart_items
    resources :combo_cart_items
    member do
      get 'combo_summary'
    end
  end

  resources :restaurants do
    resources :dishes
    resources :caterings
    member do
      get 'list_dishes' => 'restaurants#list_dishes', as: :list_dishes
    end
  end
 
  resources :locations

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
