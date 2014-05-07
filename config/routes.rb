Mysolar::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"  

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


  get 'customer' => 'index#customer'
  get 'customer/signup' => 'customer#index'
  get 'customer/details' => 'customer#details'

  get 'promoter' => 'promoter#index'
  get 'promoter/thanks' => 'promoter#thanks'
  get 'promoter/request' => 'promoter#request'
  get 'promoter/activate' => 'promoter#activate'
  
  # These are just to fake the referral pages so the link doesn't break - safe to remove when the feature is implemented
  get '/1234' => 'customer#index'
  get '/4321' => 'promoter#index'

  get 'thanks' => 'customer#thanks'

  get 'user' => 'user#index'
  get 'user/reset_password' => 'user#reset_password'

  get 'organization' => 'organization#index'

  get 'upgrade' => 'upgrade#index'

  get 'dashboard' => 'dashboard#index'

  get 'training' => 'training#index'

  get 'settings' => 'settings#index'

  root 'index#index'
end
