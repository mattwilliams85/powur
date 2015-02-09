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

    def eligible_parents
      @users = User
        .with_ancestor(current_user.id)
        .where('NOT (? = ANY (upline))', @user.id)
        .where('id <> ?', @user.parent_id)
        .order(:upline)

      render 'select_index'
    end

    def move
      require_input :parent_id
      
      child = User.find(params[:child_id])
      parent = User.find(params[:parent_id])
      child.assign_parent(parent)

      render 'show'
    end
  end
end
