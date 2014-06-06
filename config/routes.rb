Rails.application.routes.draw do

  def has_params(*args)
    ->(r){ args.none? { |a| r.params[a].blank? } }
  end

  resource :login, controller: :session, only: [ :show, :create, :destroy ] do

    resource :password, only: [ :show, :create, :new ] do
      put :update, on: :member
    end

    post 'invite' => 'session#accept_invite'
    delete 'invite' => 'session#clear_code'

    post :register
  end

  resources :invites, only: [ :index, :create, :destroy ] do
    collection do
      get '' => 'invites#search', constraints: has_params(:q)
    end
    member do
      post :resend
    end
  end

  resources :users, only: [ :index, :show ] do
    collection do
      get '' => 'users#search', constraints: has_params(:q)
    end
  end

  resource :promoter, only: [ :new, :show ] do
    get :request
    get :thanks
  end

  resources :customers, only: [ :index, :create, :destroy, :update, :show ]

  resource :quote, only: [ :new, :show ] do
    get 'details' => 'quotes#details'
  end

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
