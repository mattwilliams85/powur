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
        get '' => 'users#search', constraints: has_params(:search)
      end
    end

    resources :quotes, only: [ :index, :create, :destroy, :update, :show ], as: :user_quotes do
      collection do
        get '' => 'quotes#search', constraints: has_params(:search)
      end
      member do
        post :resend
      end
    end
  end

  # logged in admin routes
  scope :a, module: :admin do

    resources :users, only: [ :index, :show, :update ], as: :admin_users do
      collection do
        get '' => 'users#search', constraints: has_params(:search)
      end
      member do
        get :downline
        get :upline
      end
      resources :orders, only: [ :index ], controller: :user_orders
      resources :order_totals, only: [ :index ], controller: :user_order_totals
      resources :rank_achievements, only: [ :index ], controller: :user_rank_achievements
      resources :bonus_payments, only: [ :index ], controller: :user_bonus_payments
    end

    resources :products, only: [ :index, :create, :update, :show, :destroy ]

    resources :ranks, only: [ :index, :create, :update, :destroy, :show ] do
      resources :qualifications, only: [ :create, :update, :destroy ], controller: :rank_qualifications
    end

    resources :qualifications, only: [ :index, :create, :update, :destroy ]

    resources :bonus_plans, only: [ :index, :create, :destroy, :update, :show ] do
      resources :bonuses, only: [ :index, :create ], as: :bonuses
    end

    resources :bonuses, only: [ :destroy, :update, :show ] do
      resources :requirements, only: [ :create, :update, :destroy ]
      resources :bonus_levels, only: [ :create, :update, :destroy ], as: :levels
    end

    resources :quotes, only: [ :index, :show ], as: :admin_quotes do
      collection do
        get '' => 'quotes#search', constraints: has_params(:search)
      end
    end

    resources :orders, only: [ :index, :create, :show ]

    resources :pay_periods, only: [ :index, :show ] do
      member do
        post :calculate
        post :recalculate
      end
      resources :order_totals, only: [ :index ], controller: :pay_period_order_totals
      resources :rank_achievements, only: [ :index ], controller: :pay_period_rank_achievements
      resources :bonus_payments, only: [ :index ], controller: :pay_period_bonus_payments
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
