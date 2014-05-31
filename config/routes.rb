Rails.application.routes.draw do

  resource :login, controller: :session, only: [ :show, :create, :destroy ]

  resources :invites, only: [ :index, :create, :destroy ] do
    member do
      post :resend
    end
  end

  post '/invite/accept' => 'users#accept_invite'

  resources :users, only: [ :create, :show ]

  resource :promoter, only: [ :new, :show ] do
    get :request
    get :thanks
  end



  get 'customer' => 'index#customer'
  get 'customer/signup' => 'customer#index'
  get 'customer/details' => 'customer#details'

  # These are just to fake the referral pages so the link doesn't break - safe to remove when the feature is implemented
  # get '/1234' => 'customer#index'
  # get '/4321' => 'promoter#index'

  get 'thanks' => 'customer#thanks'

  get 'user' => 'user#index'
  get 'users/reset_password' => 'user#reset_password'

  get 'organization' => 'organization#index'

  get 'upgrade' => 'upgrade#index'

  get 'dashboard' => 'dashboard#index'

  get 'training' => 'training#index'

  get 'settings' => 'settings#index'

  root 'index#index'
end
