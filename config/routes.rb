Rails.application.routes.draw do
  def params?(*args)
    ->(r) { args.none? { |a| r.params[a].blank? } }
  end

  def param_values?(args)
    ->(r) { args.all? { |k, v| r.params[k] == v } }
  end

  def json?
    ->(r) { r.params[:format] == 'json' }
  end

  def html?
    ->(r) { !r.xhr? && r.format.html? }
  end

  root 'index#index'

  get 'beta', to: redirect('https://www.surveygizmo.com/s3/2168411/Beta-Application')

  # Index json request
  get 'index', to: 'index#index', constraints: json?

  # Any admin html request
  get 'admin(/*any)', to: 'admin/root#index', constraints: html?

  get 'next', to: 'next#index', constraints: html?

  # TEMPORARY
  get 'next(*anyhtml)', to: 'next#index'

  # Any other html request
  get '*anyhtml', to: 'index#index', constraints: html?

  resource :session, only: [ :show ]

  # anonymous routes
  scope module: :anon do
    resource :login, controller: :session, only: [ :show, :create, :destroy ] do
      member do
        get :assets
      end
    end

    resource :password, only: [ :show, :create, :new ] do
      member do
        put :update
      end
      get '/reset_token/:token', to: 'passwords#reset_token', as: :reset_token
    end

    resources :invites, as: :anon_invites, only: [ :show, :update ] do
    end

    resource :zip_validator, only: [ :create ] do
      post :validate
    end

    resources :users, as: :anon_users, only: [ :show ]
    resources :leads, as: :anon_leads, only: [ :show, :create, :update ]
  end

  # logged in user routes
  scope :u, module: :auth do
    resource :kpi_metrics, only: [ :show ] do
      get '/:id/proposals_index', to: 'kpi_metrics#proposals_index'
      get '/:id/proposals_show', to: 'kpi_metrics#proposals_show'
      get '/:id/proposals_show_team', to: 'kpi_metrics#proposals_show_team'
      get '/:id/genealogy_index', to: 'kpi_metrics#genealogy_index'
      get '/:id/genealogy_show_team', to: 'kpi_metrics#genealogy_show_team'

      member do
        get :show_lead_owner
      end
    end

    resources :leads, only: [ :index, :create, :destroy, :update, :show ] do
      member do
        post :resend, :submit, :invite
        patch :switch_owner
      end
      collection do
        get :team
      end
    end

    resources :ranks, only: [ :index, :create, :destroy, :show, :update ] do
      resources :groups, only: [ :index ], controller: :user_groups
      post 'groups' => 'user_groups#add_to_rank'
    end

    resources :user_groups,
              only: [ :index, :show, :create, :update, :destroy ] do
      resources :requirements, only: [ :index, :create ]
    end

    resources :requirements, only: [ :destroy, :update, :show ]

    resource :dashboard, only: [ :show ], controller: :dashboard

    resource :profile,
             only:       [ :show, :update, :password_reset,
                           :create_ewallet ],
             controller: :profile do
      put 'update_password', to: 'profile#update_password'
      patch 'update_avatar', to: 'profile#update_avatar'
      member do
        post :create_ewallet
      end
    end

    resources :invites do
      member do
        delete :delete
        post :resend
        get :email
      end
    end

    resources :pay_periods, only: [ :index, :show ] do
      member do
        post :calculate
        post :distribute
      end
      resources :users, only:       [ :index, :show ],
                        controller: :pay_period_users do
        resources :bonus_payments, only: [ :index ]
      end
    end

    resources :users, only: [ :index, :show, :user_team_counts ] do
      collection do
        get '' => 'users#search', constraints: params?(:search)
        get :leaderboard
      end

      member do
        get :downline, :full_downline, :upline, :eligible_parents, :sponsors, :grid_summary, :detail
        post :move
      end

      resources :leads, only: [ :index ] do
        collection do
          get :summary, :marketing
        end
      end
      resource :goals, only: [ :show ]
      resources :order_totals, only: [ :index ]
      resources :user_activities, only:       [ :index, :show ],
                                  controller: :user_activities
      resources :pay_periods, only:       [ :index, :show ],
                              controller: :user_pay_periods
    end

    resources :earnings,
              only:       [ :index, :show, :summary,
                            :detail, :bonus, :bonus_detail ],
              controller: :earnings do
      collection do
        get :summary
        get :detail
        get :bonus
        get :bonus_detail
      end
    end

    resources :university_classes, only: [:index, :show] do
      member do
        post :enroll, :purchase, :smarteru_signin
        get :check_enrollment
      end
    end

    resources :news_posts,
              only: [ :index, :show ],
              as:   :user_news_posts

    resources :social_media_posts,
              only: [ :index, :show ],
              as:   :user_social_media_posts

    resources :resources, only: [:index, :show]

    get 'uploader_config', to: 'uploader_config#show'
  end

  #
  # ADMIN ROUTES
  #
  # Alphabetized by Feature Name
  #

  scope :a, module: :admin do
    # Root
    get '' => 'root#index', as: :admin_root

    # Application Agreements
    resources :application_agreements, as: :admin_application_agreements do
      member do
        patch :publish, :unpublish
      end
    end

    # Lead Actions
    resources :lead_actions, only: [ :index, :destroy, :create, :update, :show ]

    # Bonuses
    resources :bonuses, only: [ :index, :destroy, :update, :show ] do
      resources :bonus_amounts, only: [ :create ], as: :amounts, path: :amounts
    end

    # Bonus Amounts
    resources :bonus_amounts, only: [ :update, :destroy ], as: :bonus_amounts

    # Bonus Plans
    resources :bonus_plans,
              only: [ :index, :create, :destroy, :update, :show ] do
      resources :bonuses, only: [ :index, :create ], as: :bonuses
    end

    resources :invites, only: [ :index ], as: :admin_invites

    # Latest News
    resources :news_posts,
              only: [ :index, :create, :destroy, :show, :update ],
              as:   :admin_news_posts

    # Library
    resources :resources, as: :admin_resources
    resources :resource_topics, as: :admin_resource_topics

    # Overrides
    resources :overrides, only: [ :index, :update, :destroy ]

    # Products
    resources :products, only: [ :index, :create, :update, :show, :destroy ]

    # Product Enrollments
    resources :product_enrollments,
              only: [ :index ],
              as:   :admin_product_enrollments

    # Product Receipts
    resources :product_receipts,
              only: [ :index ],
              as:   :admin_product_receipts do
      member do
        post :refund
      end
    end

    resources :system_settings,
              only: [ :index, :show, :update ],
              as:   :admin_system_settings

    resources :notifications, as: :admin_notifications do
      member do
        post :send_out
      end
      collection do
        get :available_recipients
      end
    end

    # Users
    resources :users, only: [ :index, :show, :update ], as: :admin_users do
      collection do
        get '' => 'users#search', constraints: params?(:search)
        get :invites
      end
      member do
        get :downline, :upline, :eligible_parents, :sponsors
        post :move, :sign_in
        patch :update_sponsor, :terminate, :unterminate
        delete :delete_user
      end

      # Users / Bonus Payments
      resources :bonus_payments,
                only:       [ :index ],
                controller: :user_bonus_payments

      # Users / Invites
      resources :invites,
                only:       [ :index, :create, :show, :destroy ],
                controller: :user_invites do
        member do
          post :resend
        end
      end

      patch 'invites', to: 'user_invites#award'

      # Users / Overrides
      resources :overrides, only: [ :index, :create ]

      # Users / Pay Periods
      # resources :pay_periods, only:       [ :index, :show ],
      #                         controller: :user_pay_periods

      # Users / Product Enrollments
      resources :product_enrollments, only: [ :index ]

      # Users / Product Receipts
      resources :product_receipts,  only: [ :index, :create ]
    end

    # Pay Periods
    # resources :pay_periods, only: [ :index, :show ] do
    #   member do
    #     post :calculate
    #     post :recalculate
    #     post :disburse
    #   end

    #   # Pay Periods / Bonus Payments
    #   resources :bonus_payments,
    #             only:       [ :index ],
    #             controller: :pay_period_bonus_payments
    # end

    # Social Media Sharing
    resources :social_media_posts,
              only: [ :index, :create, :destroy, :show, :update ],
              as:   :admin_social_media_posts

    resources :twilio_phone_numbers,
              only: [ :index ],
              as:   :admin_twilio_phone_numbers
  end

  namespace :api do
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
      post 'token' => 'token#client_credentials',
        constraints: param_values?(grant_type: 'client_credentials')
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

      namespace :data do
        resources :leads, only: [ :create ] do
          post :batch, on: :collection
        end
      end
    end
  end

  resource :promoter, only: [ :new, :show ]
end
