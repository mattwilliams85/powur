Rails.application.routes.draw do

  resource :login, controller: :session, only: [ :create, :destroy ] do
    get '' => 'session#index'
  end
  resources :invites, only: [ :index, :create, :destroy ] do
    member do
      post :renew
      post :resend
    end
    
  end


  get 'customer' => 'index#customer'
  get 'customer/signup' => 'customer#index'
  get 'customer/details' => 'customer#details'

  get 'promoter' => 'promoter#index'
  get 'promoter/create' => 'promoter#create'
  get 'promoter/thanks' => 'promoter#thanks'
  get 'promoter/request' => 'promoter#request'
  
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
