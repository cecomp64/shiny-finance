ShinyFinance::Application.routes.draw do
  root 'static_pages#home'

  resources :transactions
  resources :users
  resources :lots, only: [:new, :create, :destroy, :index]
  resources :sessions, only: [:new, :create, :destroy]

  match '/help', to: 'static_pages#help', via: 'get'
  match '/about', to: 'static_pages#about', via: 'get'
  match '/signup', to: 'users#new', via: 'get'
  match '/signin', to: 'sessions#new', via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'
  match '/import', to: 'transactions#import', via: 'get', as: 'import_transactions'
  match '/import_schwab_csv', to: 'transactions#import_schwab_csv', via: 'post', as: 'import_schwab_csv'
  #match '/transactions/analyze/:symbol', to: 'transactions#analyze', via: 'get', as: 'analyze_transaction_path'
  match '/analyze', to: 'transactions#analyze', via: 'get', as: 'analyze_transactions'
  match '/delete_my_transactions', to: 'transactions#delete_all', via: 'get', as: 'delete_all_transactions'
  match '/lots/edit', to: 'lots#edit', via: 'get', as: 'lots_edit'
  match '/lots/update', to: 'lots#update', via: 'post', as: 'lots_update'

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
