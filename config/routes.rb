Rails.application.routes.draw do

  def has_params(*args)
    ->(r){ args.none? { |a| r.params[a].blank? } }
  end

  # anonymous routes
  scope module: :anon do

    resource :login, controller: :session, only: [ :show, :create, :destroy ]

    resource :password, only: [ :show, :create, :new ] do
      put :update, on: :member
    end

    resource :invite, only: [ :create, :update, :destroy ]

  end

  # quote routes
  resource :quote, only: [ :show, :create, :update ] do
    post  :resend
    get   ':sponsor'         => 'quotes#new', as: :sponsor
    get   ':sponsor/:quote'  => 'quotes#show', as: :customer
  end


  # logged in user routes
  scope :u, module: :auth do
    resource :dashboard, only: [ :show ], controller: :dashboard

    resources :invites, only: [ :index, :create, :destroy ] do
      member do
        post :resend
      end
    end

    resources :users, only: [ :index, :show ] do
      collection do
        get '' => 'users#search', constraints: has_params(:q)
      end
    end

    resources :quotes, only: [ :index, :create, :destroy, :update, :show ], as: :user_quotes do
      collection do
        get '' => 'quotes#search', constraints: has_params(:q)
      end
      member do
        post :resend
      end
    end
  end

  resource :promoter, only: [ :new, :show ] do
    get :request
    get :thanks
  end

  # These are just to fake the referral pages so the link doesn't break - safe to remove when the feature is implemented
  # get '/1234' => 'customer#index'
  # get '/4321' => 'promoter#index'

  get 'thanks' => 'customer#thanks'

  get 'user' => 'user#index'

  get 'organization' => 'organization#index'

  get 'upgrade' => 'upgrade#index'

  get 'training' => 'training#index'

  get 'settings' => 'settings#index'

  root 'index#index'
end
