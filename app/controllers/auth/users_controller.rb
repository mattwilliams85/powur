module Auth
  class UsersController < AuthController
    include UsersActions

    sort user: 'users.last_name asc, users.first_name asc'
    filter :performance,
           fields:     { metric: { options: { quotes:   'Quote Count',
                                              personal: 'Personal Sales',
                                              group:    'Group Sales' },
                                   heading: :order_by },
                         period: { options: { lifetime: 'Lifetime',
                                              monthly:  'Monthly',
                                              weekly:   'Weekly' },
                                   heading: :for_period } },
           scope_opts: { type: :hash, using: [ :metric, :period ] }
  end
end
