Rails.application.routes.draw do

  def params?(*args)
    ->(r) { args.none? { |a| r.params[a].blank? } }
  end

  def param_values?(args)
    ->(r) { args.all? { |k, v| r.params[k] == v } }
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
    post :resend
    get ':sponsor' => 'quotes#new', as: :sponsor
    get ':sponsor/:quote' => 'quotes#show', as: :customer
  end

  # logged in user routes
  scope :u, module: :auth do
    resource :kpi_metrics, only: [ :show ]
    
    resource :dashboard, only: [ :show ], controller: :dashboard

    resource :empower_merchant, only: [ :sandbox, :process_card, :confirmation ], controller: :empower_merchant do
      get 'sandbox', to: 'empower_merchant#sandbox'
      get 'confirmation', to: 'empower_merchant#confirmation'
      collection do
        post 'process_card' => 'empower_merchant', as: :process_card
      end
    end

    resource :ewallet, only:       [ :index, :account_details ],
                       controller: :ewallet do
      get 'account_details', to: 'ewallet#account_details'

    end
    resource :profile,
             only:       [ :show, :update, :password_reset ],
             controller: :profile do
      post 'update_password', to: 'profile#update_password'
      patch 'update_avatar', to: 'profile#update_avatar'
    end

    resources :invites, only: [ :index, :create, :destroy ] do
      member do
        post :resend
      end
    end

    resources :users, only: [ :index, :show ] do
      collection do
        get '' => 'users#search', constraints: params?(:search)
      end

      resource :goals, only: [ :show ]
      resources :orders, only: [ :index, :show ], controller: :user_orders
      resources :order_totals, only: [ :index ], controller: :user_order_totals
      resources :user_activities, only:       [ :index, :show ],
                                  controller: :user_activities
      member do
        get :downline
        get :upline
      end

      resources :rank_achievements, only:       [ :index ],
                                    controller: :user_rank_achievements
    end

    resources :quotes, only: [ :index, :create, :destroy, :update, :show ],
                       as:   :user_quotes do
      member do
        post :resend
      end
    end

    resource :earnings, only: [:show]

    resources :ewallet_sandbox, only:       [ :index, :call ],
                                controller: :ewallet_sandbox do
      collection do
        post 'call' => 'ewallet_sandbox', as: :call
      end
    end
  end

  # logged in admin routes
  scope :a, module: :admin do

    get '' => 'root#index', as: :admin_root

    resources :users, only: [ :index, :show, :update ], as: :admin_users do
      collection do
        get '' => 'users#search', constraints: params?(:search)
      end
      member do
        get :downline
        get :upline
      end
      resources :overrides, only: [ :index, :create ]

      resources :ewallet_sandbox, only: [ :index, :call ], controller: :ewallet_sandbox do
        collection do
          post 'call' => 'ewallet_sandbox', as: :call
        end
      end

      resources :pay_periods, only: [ :index, :show ], controller: :user_pay_periods

      resources :orders, only: [ :index ], controller: :user_orders
      resources :order_totals, only: [ :index ], controller: :user_order_totals
      resources :rank_achievements,
                only:       [ :index ],
                controller: :user_rank_achievements
      resources :bonus_payments,
                only:       [ :index ],
                controller: :user_bonus_payments
    end

    resource :system, only: [ :index, :show ] do
      collection do
        get :quotes
      end
    end

    resources :products, only: [ :index, :create, :update, :show, :destroy ]

    resources :ranks, only: [ :index, :create, :update, :destroy, :show ] do
      resources :qualifications,
                only:       [ :create, :update, :destroy ],
                controller: :rank_qualifications
    end

    resources :rank_paths, only: [ :index, :create, :update, :destroy ]

    resources :qualifications, only: [ :index, :create, :update, :destroy ]

    resources :bonus_plans,
              only: [ :index, :create, :destroy, :update, :show ] do
      resources :bonuses, only: [ :index, :create ], as: :bonuses
    end

    resources :bonuses, only: [ :index, :destroy, :update, :show ] do
      resources :requirements, only: [ :create, :update, :destroy ]
      resources :bonus_levels, only: [ :create ], as: :levels
    end
    resources :bonus_levels, only: [ :update, :destroy ], as: :bonus_levels

    resources :quotes, only: [ :index, :show ], as: :admin_quotes do
      collection do
        get '' => 'quotes#search', constraints: params?(:search)
      end
    end

    resources :orders, only: [ :index, :create, :show ], as: :admin_orders do
      resources :bonus_payments,
                only:       [ :index ],
                controller: :order_bonus_payments
    end

    resources :pay_periods, only: [ :index, :show ] do
      member do
        post :calculate
        post :recalculate
        post :disburse
      end
      resources :orders, only: [ :index ], controller: :pay_period_orders
      resources :order_totals,
                only:       [ :index ],
                controller: :pay_period_order_totals
      resources :rank_achievements,
                only:       [ :index ],
                controller: :pay_period_rank_achievements
      resources :bonus_payments,
                only:       [ :index ],
                controller: :pay_period_bonus_payments
    end

    resources :overrides, only: [ :index, :update, :destroy ]
  end

  scope :gateway, module: :gateway do
    get 'ipayout/verify_user', to: 'ipayout#verify_user'
    post 'ipayout/notify_merchant', to: 'ipayout#notify_merchant'
  end

  namespace :api, defaults: { format: 'json' } do
    # backwards compat. example
    # namespace :v1 do
    #   resource :session, only: [ :show ]
    # end

    root to: 'root#show'

    scope '(v:v)' do
      resource :password, only: [ :create ]
      post 'token' => 'token#ropc',
        constraints: param_values?(grant_type: 'password')
      post 'token' => 'token#refresh_token',
        constraints: param_values?(grant_type: 'refresh_token')
      post 'token' => 'token#unsupported_grant_type',
        constraints: params?(:grant_type)
      post 'token' => 'token#invalid_request'

      resource :session, only: [ :show ]
      resources :users, only: [ :index, :show ] do
        member do
          get :downline
        end
      end
      resources :invites, only: [ :index, :create, :destroy ] do
        member do
          post :resend
        end
      end
      resources :quotes, only: [ :index, :create ]
    end
  end

  resource :promoter, only: [ :new, :show ]

  root 'index#index'
end
