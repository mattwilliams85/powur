Rails.application.routes.draw do

  resource :login, controller: :session, only: [ :show, :create, :destroy ] do
    resource :password, only: [ :show, :create ]
    post 'invite' => 'session#accept_invite'
    delete 'invite' => 'session#clear_code'
    post :register
  end

  resources :invites, only: [ :index, :create, :destroy ] do
    member do
      post :resend
    end
  end

  resources :users, only: [ :index, :show ] do
  end

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

  get 'organization' => 'organization#index'

  get 'upgrade' => 'upgrade#index'

  get 'dashboard' => 'dashboard#index'

  get 'training' => 'training#index'

  get 'settings' => 'settings#index'

  root 'index#index'
end
